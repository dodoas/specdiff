# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test)

require "rubocop/rake_task"

RuboCop::RakeTask.new(:lint)

task default: %i[test lint]
