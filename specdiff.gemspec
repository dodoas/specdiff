# frozen_string_literal: true

require_relative "lib/specdiff/version"

Gem::Specification.new do |spec|
  spec.name = "specdiff"
  spec.version = Specdiff::VERSION
  spec.authors = ["Odin Heggvold Bekkelund"]
  spec.email = ["odin.heggvold.bekkelund@dev.dodo.no"]

  spec.summary = "Improved diffing for WebMock and RSpec"
  spec.description = <<~TXT
    Specdiff aims to improve both RSpec's and WebMock's diffing by applying \
    opinionated heuristics, and comes with integrations (monkey-patches) for \
    both. Particularly noteworthy improvements are made to working with deeply \
    nested hash/array structures in RSpec, and plaintext/xml request bodies in \
    WebMock.
  TXT

  spec.homepage = "https://github.com/dodoas/specdiff"
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
