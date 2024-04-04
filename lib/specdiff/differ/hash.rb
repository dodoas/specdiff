require "hashdiff"

class Specdiff::Differ::Hash
  extend ::Specdiff::Colorize

  VALUE_CHANGE_PERCENTAGE_THRESHOLD = 0.2
  TOTAL_CHANGES_FOR_GROUPING_THRESHOLD = 9

  NEWLINE = "\n"

  def self.diff(a, b)
    # array_path: true returns the path as an array, which differentiates
    # between symbol keys and string keys in hashes, while the string
    # representation does not.
    # hmm it really seems like use_lcs: true gives much less human-readable
    # (human-comprehensible) output when arrays are involved.
    hashdiff_diff = ::Hashdiff.diff(
      a.value, b.value,
      array_path: true,
      use_lcs: false,
    )

    return hashdiff_diff if hashdiff_diff.empty?

    change_percentage = _calculate_change_percentage(hashdiff_diff)

    if change_percentage >= VALUE_CHANGE_PERCENTAGE_THRESHOLD
      hashdiff_diff
    else
      a_text = ::Specdiff.hashprint(a.value)
      b_text = ::Specdiff.hashprint(b.value)

      text_diff = ::Specdiff.diff(a_text, b_text)

      if text_diff.empty?
        []
      else
        text_diff
      end
    end
  end

  def self._calculate_change_percentage(hashdiff_diff)
    value_change_count = hashdiff_diff.count { |element| element[0] == "~" }
    addition_count = hashdiff_diff.count { |element| element[0] == "+" }
    deletion_count = hashdiff_diff.count { |element| element[0] == "-" }
    # puts "hashdiff_diff: #{hashdiff_diff.inspect}"
    # puts "value_change_count: #{value_change_count.inspect}"
    # puts "addition_count: #{addition_count.inspect}"
    # puts "deletion_count: #{deletion_count.inspect}"

    total_number_of_changes = [
      value_change_count,
      addition_count,
      deletion_count,
    ].sum

    change_fraction = Rational(value_change_count, total_number_of_changes)
    change_percentage = change_fraction.to_f
    # puts "change_fraction: #{change_fraction.inspect}"
    # puts "change_percentage: #{change_percentage.inspect}"

    change_percentage
  end

  def self.empty?(diff)
    diff.raw.empty?
  end

  def self.stringify(diff)
    result = +""
    return result if diff.empty?

    total_changes = diff.raw.size
    group_with_newlines = total_changes >= TOTAL_CHANGES_FOR_GROUPING_THRESHOLD

    # hashdiff returns a structure like so:
    # change[0] = '+', '-' or '~'. denoting type (addition, deletion or change)
    # change[1] = the path to the change, in array form
    # change[2] = the value, or the from value in case of '~'
    # change[3] = the to value, only present when '~'
    changes_grouped_by_type = diff.raw.group_by { |change| change[0] }
    if (changes_grouped_by_type.keys - ["+", "-", "~"]).size > 0
      $stderr.puts(
        "Specdiff: hashdiff returned unexpected types: #{diff.raw.inspect}"
      )
    end

    deletions = changes_grouped_by_type["-"] || []
    additions = changes_grouped_by_type["+"] || []
    value_changes = changes_grouped_by_type["~"] || []

    result << "@@ +#{additions.size}/-#{deletions.size}/~#{value_changes.size} @@"
    result << NEWLINE

    deletions.each do |change|
      value = change[2]
      path = _stringify_path(change[1])

      result << "missing key: #{path} (#{::Specdiff.diff_inspect(value)})"
      result << NEWLINE
    end

    if deletions.any? && additions.any? && group_with_newlines
      result << NEWLINE
    end

    additions.each do |change|
      value = change[2]
      path = _stringify_path(change[1])

      result << "  extra key: #{path} (#{::Specdiff.diff_inspect(value)})"
      result << NEWLINE
    end

    if additions.any? && value_changes.any? && group_with_newlines
      result << NEWLINE
    end

    value_changes.each do |change|
      from = change[2]
      to = change[3]
      path = _stringify_path(change[1])

      from_inspected = ::Specdiff.diff_inspect(from)
      to_inspected = ::Specdiff.diff_inspect(to)
      result << "  new value: #{path} (#{from_inspected} -> #{to_inspected})"
      result << NEWLINE
    end

    colorize_by_line(result) do |line|
      if line.start_with?("missing key:")
        red(line)
      elsif line.start_with?("  extra key:")
        green(line)
      elsif line.start_with?("  new value:")
        yellow(line)
      elsif line.start_with?("@@")
        cyan(line)
      else
        reset_color(line)
      end
    end
  end

  PATH_SEPARATOR = ".".freeze

  def self._stringify_path(path)
    result = +""

    path.each do |component|
      if component.is_a?(Numeric)
        result.chomp!(PATH_SEPARATOR)
        result << "[#{component}]"
      elsif component.is_a?(Symbol)
        # by not inspecting symbols they look prettier than strings, but you
        # can still tell the difference in the printed output
        result << component.to_s
      else
        result << component.inspect
      end

      result << PATH_SEPARATOR
    end

    result.chomp(PATH_SEPARATOR)
  end
end
