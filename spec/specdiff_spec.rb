RSpec.describe Specdiff do
  it "has a version number" do
    expect(Specdiff::VERSION).not_to be nil
  end

  it "can be configured" do
    original_config = Specdiff.config.dup

    expect(Specdiff.config.colorize).to eq(false)
    Specdiff.configure do |config|
      config.colorize = true
    end

    expect(Specdiff.config.colorize).to eq(true)
  ensure
    Specdiff._set_config(original_config)
  end
end
