require "hashdiff"

class Specdiff::Differ::Hash
  extend ::Specdiff::Colorize

  # The percentage of changes that must (potentially) be a key rename in a hash
  # for text diffing to kick in. Expressed as a fraction of 1.
  KEY_CHANGE_PERCENTAGE_THRESHOLD = 0.8

  # The number of changes that must be detected by hashdiff before we print some
  # extra newlines to better group extra/missing/new_values visually.
  TOTAL_CHANGES_FOR_GROUPING_THRESHOLD = 9

  def self.diff(a, b)
    # array_path: true returns the path as an array, which differentiates
    # between symbol keys and string keys in hashes, while the string
    # representation does not.

    # hmm it really seems like use_lcs: true gives much less human-readable
    # (human-comprehensible) output when arrays are involved.

    # use_lcs: true may also cause Hashdiff to use a lot of memory when BIG
    # arrays are involved: https://github.com/liufengyun/hashdiff/issues/49
    # so we might as well avoid that problem altogether.
    hashdiff_diff = ::Hashdiff.diff(
      a.value, b.value,
      array_path: true,
      use_lcs: false,
    )

    return hashdiff_diff if hashdiff_diff.empty?

    change_percentage = _calculate_change_percentage(hashdiff_diff)

    if change_percentage <= KEY_CHANGE_PERCENTAGE_THRESHOLD
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
    extra_keys = hashdiff_diff.count { |element| element[0] == "+" }
    missing_keys = hashdiff_diff.count { |element| element[0] == "-" }
    new_values = hashdiff_diff.count { |element| element[0] == "~" }
    # puts "hashdiff_diff: #{hashdiff_diff.inspect}"
    # puts "extra_keys: #{extra_keys.inspect}"
    # puts "missing_keys: #{missing_keys.inspect}"
    # puts "new_values: #{new_values.inspect}"

    potential_changed_keys = [extra_keys, missing_keys].min
    adjusted_extra_keys = extra_keys - potential_changed_keys
    adjusted_missing_keys = missing_keys - potential_changed_keys
    # puts "potential_changed_keys: #{potential_changed_keys.inspect}"
    # puts "adjusted_extra_keys: #{adjusted_extra_keys.inspect}"
    # puts "adjusted_missing_keys: #{adjusted_missing_keys.inspect}"

    non_changed_keys = adjusted_extra_keys + adjusted_missing_keys + new_values
    total_changes = non_changed_keys + potential_changed_keys
    # puts "non_changed_keys: #{non_changed_keys.inspect}"
    # puts "total_changes: #{total_changes.inspect}"

    key_change_fraction = Rational(potential_changed_keys, total_changes)
    key_change_percentage = key_change_fraction.to_f
    # puts "key_change_fraction: #{key_change_fraction.inspect}"
    # puts "key_change_percentage: #{key_change_percentage.inspect}"

    key_change_percentage
  end

  def self.empty?(diff)
    diff.raw.empty?
  end

  NEWLINE = "\n"

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
