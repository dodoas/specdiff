::Specdiff::Diff = Struct.new(
  :differ, :a, :b, :raw, keyword_init: true,
) do
  def differ_id
    differ.id
  end

  def to_s
    differ.stringify(self)
  end

  def empty?
    differ == ::Specdiff::Differ::NotFound ||
      (differ.respond_to?(:empty?) && differ.empty?(self))
  end

  def types
    [a.type, b.type]
  end

  def inspect
    raw_diff = if empty?
                 "empty"
               elsif differ == ::Specdiff::Differ::Text
                 bytes = raw&.bytesize || 0
                 "#{bytes} bytes of #raw diff"
               else
                 "#{raw.inspect}"
               end

    "<Specdiff::Diff (#{a.type}/#{b.type}) (#{differ}) (#{raw_diff})>"
  end
end
