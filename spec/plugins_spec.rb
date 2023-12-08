# rubocop: disable Lint/UnusedMethodArgument
RSpec.describe "plugins" do
  after(:each) do
    Specdiff._clear_plugins!
  end

  it "allows you to define and use a custom type" do
    my_custom_type = Class.new do
      include ::Specdiff::Plugin

      def self.id
        :my_custom_type
      end

      def self.detect_type(thing)
        thing.is_a?(String) && thing.start_with?("lol")
      end

      def self.diff(a, b)
        "my_custom_type_diff_output"
      end

      def self.stringify(diff)
        diff.raw
      end
    end

    expect {
      Specdiff.load!(my_custom_type)
    }.to change { Specdiff.plugins.size }.from(0).to(1)

    result = Specdiff.diff("lolvalue", "loltest")
    expect(result.types).to eq([:my_custom_type, :my_custom_type])
    expect(result.to_s).to eq("my_custom_type_diff_output")
  end

  it "validates methods implemented by plugins" do
    object = Object.new
    def object.inspect
      "<just_an_object>"
    end

    expect {
      Specdiff.load!(object)
    }.to raise_error(<<~MSG)
      plugin <just_an_object> does not respond to required methods:
      these are required: [:id, :detect_type, :compatible?, :diff, :stringify]
      these were missing: [:id, :detect_type, :compatible?, :diff, :stringify]
    MSG

    reasonable_attempt = Class.new do
      def self.id
        :my_cool_type
      end

      def self.diff(a, b)
        "some kinda output"
      end

      def self.inspect
        "<reasonable_attempt>"
      end
    end

    expect {
      Specdiff.load!(reasonable_attempt)
    }.to raise_error(<<~MSG)
      plugin <reasonable_attempt> does not respond to required methods:
      these are required: [:id, :detect_type, :compatible?, :diff, :stringify]
      these were missing: [:detect_type, :compatible?, :stringify]
    MSG
      .and change { Specdiff.plugins.size }.by(0)
  end

  it "doesn't require #detect_type to be defined if #id returns a builtin type" do
    differ_of_builtins = Class.new do
      def self.id
        :hash
      end

      def self.inspect
        "<hmm>"
      end
    end

    expect {
      Specdiff.load!(differ_of_builtins)
    }.to raise_error(<<~MSG)
      plugin <hmm> does not respond to required methods:
      these are required: [:id, :compatible?, :diff, :stringify]
      these were missing: [:compatible?, :diff, :stringify]
    MSG
      .and change { Specdiff.plugins.size }.by(0)
  end

  it "allows you to register a plugin for a built in type" do
    differ_of_arrays = Class.new do
      include ::Specdiff::Plugin

      def self.id
        :array
      end

      def self.diff(a, b)
        "a is a different (ARRAY) than b D:"
      end

      def self.stringify(diff)
        diff.raw
      end
    end

    expect {
      Specdiff.load!(differ_of_arrays)
    }.to change { Specdiff.plugins.size }.from(0).to(1)

    result = Specdiff.diff([], [1])
    expect(result.types).to eq([:array, :array])
    expect(result.empty?).to eq(false)
    expect(result.to_s).to eq("a is a different (ARRAY) than b D:")
  end

  it "disallows registering a plugin for the :unknown type" do
    differ_of_unknowns = Class.new do
      include ::Specdiff::Plugin

      def self.id
        :unknown
      end

      def self.diff(a, b)
        "a is a different unknown than b ????"
      end

      def self.stringify(diff)
        diff.raw
      end

      def self.inspect
        "<nope>"
      end
    end

    expect {
      Specdiff.load!(differ_of_unknowns)
    }.to raise_error(<<~MSG)
      plugin <nope> defined #id to = :unknown, but this is not allowed because \
      it would undermine the utility of the #empty? method on the diff.
    MSG
      .and change { Specdiff.plugins.size }.by(0)
  end
end

# rubocop: enable Lint/UnusedMethodArgument
