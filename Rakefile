# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test)

require "rubocop/rake_task"

RuboCop::RakeTask.new(:lint)

task default: %i[test lint]

desc <<~DESC
  Check how big the ruby gem is when packaged. This helps you avoid pushing \
  bloated packages with unneccessary files in them.
DESC
task :inspect_build do
  output_path = "tmp/sizetest.gem"
  sh "gem build -o #{output_path}"
  size = File.size(output_path)
  puts
  puts "== BUILD SIZE: #{size} bytes =="
  puts

  unpacking_directory = "tmp/sizetest"
  mkdir_p unpacking_directory

  sh "tar xf #{output_path} --directory #{unpacking_directory}"

  puts
  puts "== THESE FILES WERE INCLUDED IN YOUR BUILD =="
  sh "tar ztf #{unpacking_directory}/data.tar.gz"

  puts
  rm output_path
  rm_r unpacking_directory
end

desc "Run some of the release procedure automatically (that which is automatable)"
task prerelease: %i[test lint inspect_build]
