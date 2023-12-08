module Specdiff::Differ
end

# require only the builtin differs, plugins are optionally loaded later
require_relative "differ/not_found"
require_relative "differ/text"
require_relative "differ/hashdiff"
