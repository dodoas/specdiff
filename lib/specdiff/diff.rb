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
    differ == ::Specdiff::Differ::NotFound
  end

  def types
    [a.type, b.type]
  end

  def inspect
    if empty?
      "<Specdiff::Diff (empty)>"
    else
      "<Specdiff::Diff w/ #{raw&.bytesize || 0} bytes of #raw diff>"
    end
  end
end
