class Specdiff::Compare
  Side = Struct.new(:value, :type, keyword_init: true)

  def self.call(...)
    new.call(...)
  end

  def call(raw_a, raw_b)
    a = parse_side(raw_a)
    b = parse_side(raw_b)

    if a.type == :text && b.type == :binary
      new_b = try_reencode(b.value, a.value.encoding)
      if new_b
        b = b.dup
        b.type = :text
        b.value = new_b
      end
    elsif a.type == :binary && b.type == :text
      new_a = try_reencode(a.value, b.value.encoding)
      if new_a
        a = a.dup
        a.type = :text
        a.value = new_a
      end
    end

    differ = pick_differ(a, b)
    raw = differ.diff(a, b)

    if raw.is_a?(::Specdiff::Diff) # detect recursive plugins, such as json
      raw
    else
      ::Specdiff::Diff.new(raw: raw, differ: differ, a: a, b: b)
    end
  end

private

  def parse_side(raw_value)
    type = detect_type(raw_value)

    Side.new(value: raw_value, type: type)
  end

  def detect_type(thing)
    if (type = detect_plugin_types(thing))
      type
    elsif thing.is_a?(Hash)
      :hash
    elsif thing.is_a?(Array)
      :array
    elsif thing.is_a?(String) && thing.encoding == Encoding::BINARY
      :binary
    elsif thing.is_a?(String)
      :text
    elsif thing.nil?
      :nil
    else
      :unknown
    end
  end

  def detect_plugin_types(thing)
    Specdiff.plugins
      .filter { |plugin| plugin.respond_to?(:detect_type) }
      .detect { |plugin| plugin.detect_type(thing) }
      &.id
  end

  def try_reencode(binary_string, target_encoding)
    binary_string.encode(target_encoding)
  rescue StandardError
    nil
  end

  def pick_differ(a, b)
    if (differ = pick_plugin_differ(a, b))
      differ
    elsif a.type == :text && b.type == :text
      Specdiff::Differ::Text
    elsif a.type == :hash && b.type == :hash
      Specdiff::Differ::Hashdiff
    elsif a.type == :array && b.type == :array
      Specdiff::Differ::Hashdiff
    else
      Specdiff::Differ::NotFound
    end
  end

  def pick_plugin_differ(a, b)
    Specdiff.plugins
      .detect { |plugin| plugin.compatible?(a, b) }
  end
end
