require_relative "specdiff/version"
require_relative "specdiff/config"
require_relative "specdiff/colorize"
require_relative "specdiff/inspect"
require_relative "specdiff/hashprint"
require_relative "specdiff/compare"

module Specdiff
  def self.diff(...)
    ::Specdiff::Compare.call(...)
  end

  def self.hashprint(...)
    ::Specdiff::Hashprint.call(...)
  end

  def self.diff_inspect(...)
    ::Specdiff::Inspect.call(...)
  end
end

require_relative "specdiff/diff"
require_relative "specdiff/differ"
require_relative "specdiff/plugin"
require_relative "specdiff/plugins"
