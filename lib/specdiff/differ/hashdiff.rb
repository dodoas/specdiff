require "hashdiff"

class Specdiff::Differ::Hashdiff
  extend ::Specdiff::Colorize

  def self.diff(a, b)
    # array_path: true returns the path as an array, which differentiates
    # between symbol keys and string keys in hashes, while the string
    # representation does not.
    # hmm it really seems like use_lcs: true gives much less human-readable
    # (human-comprehensible) output when arrays are involved.
    ::Hashdiff.diff(
      a.value, b.value,
      array_path: true,
      use_lcs: false,
    )
  end

  def self.empty?(diff)
    diff.raw.empty?
  end

  def self.stringify(diff)
    result = +""

    diff.raw.each do |change|
      type = change[0] # the char '+', '-' or '~'
      path = change[1] # for example key1.key2[2] (as ["key1", :key2, 2])
      path2 = _stringify_path(path)

      if type == "+"
        value = change[2]

        result << "new key: #{path2} (#{value.inspect})"
      elsif type == "-"
        value = change[2]

        result << "missing key: #{path2} (#{value.inspect})"
      elsif type == "~"
        from = change[2]
        to = change[3]

        result << "#{path2} changed (#{from.inspect} => #{to.inspect})"
      else
        result << change.inspect
      end

      result << "\n"
    end

    colorize_by_line(result) do |line|
      if line.start_with?("missing key:")
        red(line)
      elsif line.start_with?("new key:")
        green(line)
      elsif line.include?("changed")
        yellow(line)
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
