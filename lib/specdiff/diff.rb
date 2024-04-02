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
    if empty?
      "<Specdiff::Diff (empty)>"
    elsif raw.respond_to?(:bytesize)
      "<Specdiff::Diff w/ #{raw&.bytesize || 0} bytes of #raw diff>"
    else
      "<Specdiff::Diff #{raw.inspect}>"
    end
  end
end
