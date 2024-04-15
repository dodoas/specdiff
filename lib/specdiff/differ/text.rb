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
      return colorize_by_line(<<~MSG) do |line|
        Strings have different encodings:
          #{a.value.encoding.inspect} != #{b.value.encoding.inspect}
      MSG
        # makes it stand out a bit more from the red of rspec output
        reset_color(line)
      end
    end

    diff = ""

    # if there are no newlines then the text differ doesn't produce any valuable
    # output. "word diffing" would improve this case.
    if a_value.count(NEWLINE) <= 1 && b_value.count(NEWLINE) <= 1
      return diff
    end

    a_lines = a_value.split(NEWLINE).map! { _1.chomp }
    b_lines = b_value.split(NEWLINE).map! { _1.chomp }

    file_length_difference = 0

    hunks = ::Diff::LCS.diff(a_lines, b_lines).map do |piece|
      ::Diff::LCS::Hunk.new(
        a_lines, b_lines, piece, CONTEXT_LINES, file_length_difference,
      ).tap { |hunk| file_length_difference = hunk.file_length_difference }
    end

    hunks.each_cons(2) do |prev_hunk, current_hunk|
      begin
        if current_hunk.overlaps?(prev_hunk)
          current_hunk.merge(prev_hunk)
        else
          diff << prev_hunk.diff(:unified)
        end
      ensure
        diff << NEWLINE
      end
    end

    if hunks.last
      diff << NEWLINE
      diff << hunks.last.diff(:unified)
    end

    return diff if diff == ""

    diff << NEWLINE
    diff.lstrip!

    return colorize_by_line(diff) do |line|
      case line[0].chr
      when "+"
        green(line)
      when "-"
        red(line)
      when "@"
        if line[1].chr == "@"
          cyan(line)
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
