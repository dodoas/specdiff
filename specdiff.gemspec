# frozen_string_literal: true

require_relative "lib/specdiff/version"

Gem::Specification.new do |spec|
  spec.name = "specdiff"
  spec.version = Specdiff::VERSION
  spec.authors = ["Odin Heggvold Bekkelund"]
  spec.email = ["odinhb@protonmail.com"]

  spec.summary = "Improved request body diffs for webmock"
  spec.homepage = "https://github.com/odinhb/specdiff"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files =
    Dir["*.gemspec"] +
    Dir["*.md"] +
    Dir["*.txt"] +
    Dir[".gitignore"] +
    Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "hashdiff", "~> 1.0"
  spec.add_dependency "diff-lcs", "~> 1.5"
end
