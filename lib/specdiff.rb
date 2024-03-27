require_relative "specdiff/version"
require_relative "specdiff/config"
require_relative "specdiff/colorize"
require_relative "specdiff/inspect"
require_relative "specdiff/hashprint"
require_relative "specdiff/compare"

module Specdiff
  # Compare two things, returns a Specdiff::Diff.
  def self.diff(...)
    ::Specdiff::Compare.call(...)
  end

  # Use Specdiff's implementation for turning a nested hash/array structure
  # into a string. Optimized for diff quality.
  def self.hashprint(...)
    ::Specdiff::Hashprint.call(...)
  end

  # Use Specdiff's inspect, which has some extra logic layered in for
  # dates/time/bigdecimal. For most objects this just delegates to #inspect.
  def self.diff_inspect(...)
    ::Specdiff::Inspect.call(...)
  end
end

require_relative "specdiff/diff"
require_relative "specdiff/differ"
require_relative "specdiff/plugin"
require_relative "specdiff/plugins"
