# this is the null differ
class Specdiff::Differ::NotFound
  def self.diff(a, b)
    comparison = "!="
    comparison = "==" if a.value == b.value

    a_representation = _representation_for(a)
    b_representation = _representation_for(b)

    "#{a_representation} #{comparison} #{b_representation}"
  end

  def self._representation_for(side)
    if side.type == :binary
      "<binary content>"
    else
      side.value.inspect
    end
  end

  def self.stringify(diff)
    diff.raw
  end
end
