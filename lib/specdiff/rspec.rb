class RSpec::Support::Differ
  alias old_diff diff

  def diff(actual, expected)
    # puts "actual, expected"
    diff = Specdiff.diff(expected, actual)
    if diff.empty?
      ""
    else
      "\n#{diff}"
    end
  end
end
