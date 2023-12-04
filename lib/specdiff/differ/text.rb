require "diff/lcs"
require "diff/lcs/hunk"

class Specdiff::Differ::Text
  extend ::Specdiff::Colorize

  NEWLINE = "\n".freeze
  CONTEXT_LINES = 3

  # this implementation is based on RSpec::Support::Differ
  # https://github.com/rspec/rspec-support/blob/main/lib/rspec/support/differ.rb
  # and also the hunk generator it uses
  def self.diff(a, b)
    a_value = a.value
    b_value = b.value

    if a_value.encoding != b_value.encoding
      return <<~MSG
        Strings have different encodings:
          #{a.value.encoding.inspect} != #{b.value.encoding.inspect}
      MSG
    end

    diff = ""

    a_lines = a_value.split(NEWLINE).map! { _1.chomp }
    b_lines = b_value.split(NEWLINE).map! { _1.chomp }
    hunks = ::Diff::LCS.diff(a_lines, b_lines).map do |piece|
      ::Diff::LCS::Hunk.new(
        a_lines, b_lines, piece, CONTEXT_LINES, 0,
      )
    end

    hunks.each_cons(2) do |prev_hunk, current_hunk|
      begin
        if current_hunk.overlaps?(prev_hunk)
          current_hunk.merge(prev_hunk)
        else
          diff << prev_hunk.diff(:unified).to_s
        end
      ensure
        diff << NEWLINE
      end
    end

    if hunks.last
      diff << hunks.last.diff(:unified).to_s
    end

    return diff if diff == ""

    diff << "\n"

    return colorize_by_line(diff) do |line|
      case line[0].chr
      when "+"
        green(line)
      when "-"
        red(line)
      when "@"
        if line[1].chr == "@"
          blue(line)
        else
          reset_color(line)
        end
      else
        reset_color(line)
      end
    end
  end

  def self.empty?(diff)
    diff.raw == ""
  end

  def self.stringify(diff)
    diff.raw
  end
end
