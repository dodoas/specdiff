class RSpec::Support::Differ
  alias old_diff diff

  def diff(actual, expected)
    diff = ::Specdiff.diff(expected, actual)
    if diff.empty?
      ""
    else
      "\n#{diff}"
    end
  end
end

# This stops rspec from truncating strings w/ ellipsis, as well as making the
# "inspect" output consistent with specdiff's.
class RSpec::Support::ObjectFormatter
  def format(object)
    # Turns out rspec uses it's crazy inspection logic for printing matcher
    # descriptions when using multiple matchers with .all, .or or .and.
    if ::RSpec::Support.is_a_matcher?(object) && object.respond_to?(:description)
      return object.description
    end

    ::Specdiff.diff_inspect(object)
  end
end
