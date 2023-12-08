RSpec.describe Specdiff do
  it "has a version number" do
    expect(Specdiff::VERSION).not_to be nil
  end

  it "can be configured" do
    original_config = Specdiff.config.dup

    expect(Specdiff.config.colorize).to eq(false)
    configure_return = Specdiff.configure do |config|
      config.colorize = true
    end

    expect(Specdiff.config.colorize).to eq(true)
    expect(configure_return).to eq(Specdiff.config)
  ensure
    Specdiff._set_config(original_config)
  end
end
