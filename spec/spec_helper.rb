require "specdiff"

def fixture_path
  Pathname.new("#{__dir__}/fixtures")
end

Specdiff.configure do |config|
  config.colorize = false
end

RSpec.configure do |config|
  # enable test focusing
  config.filter_run_when_matching :focus

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
