raise "rspec must be required before specdiff/rspec!" unless defined?(RSpec)
raise "RSpec::Support is missing????" unless defined?(RSpec::Support)

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
    ::Specdiff.diff_inspect(object)
  end
end

# marker for successfully loading this integration
class Specdiff::RSpecIntegration; end # rubocop: disable Lint/EmptyClass
