require_relative "specdiff/version"
require_relative "specdiff/threadlocal"
require_relative "specdiff/config"
require_relative "specdiff/colorize"

module Specdiff
  # Diff two things
  def self.diff(...)
    ::Specdiff::Differ.call(...)
  end
end

require_relative "specdiff/diff"
require_relative "specdiff/differ"
require_relative "specdiff/plugin"
require_relative "specdiff/plugins"
