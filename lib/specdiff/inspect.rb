class Specdiff::Inspect
  TIME_FORMAT = "%Y-%m-%d %H:%M:%S %z"
  DATE_FORMAT = "%Y-%m-%d"

  def self.call(...)
    new.call(...)
  end

  def initialize
    @recursion_trail = []
  end

  # #=== allows us to rely on Module implementing #=== instead of relying on the
  # thing (which could be any kind of wacky object) having to implement
  # #is_a? or #kind_of?
  def call(thing)
    if Hash === thing || Array === thing
      recursive_replace_inspect(thing).inspect
    elsif Time === thing
      "#<Time: #{thing.strftime(TIME_FORMAT)}>"
    elsif DateTime === thing
      "#<DateTime: #{thing.rfc3339}>"
    elsif Date === thing
      "#<Date: #{thing.strftime(DATE_FORMAT)}>"
    elsif defined?(BigDecimal) && BigDecimal === thing
      "#<BigDecimal: #{thing.to_s('F')}>"
    elsif rspec_matcher?(thing)
      # Turns out rspec depends on the recursion in its inspection logic to
      # print the "description" of rspec matchers, in situations such as when
      # using multi-matchers (.all, .or or .and), or when nesting them inside
      # eachother (such as match([have_attributes(...)])).
      thing.description
    else
      begin
        thing.inspect
      rescue NoMethodError
        inspect_anyway(thing)
      end
    end
  end

  private def rspec_matcher?(thing)
    defined?(::Specdiff::RSpecIntegration) &&
      ::RSpec::Support.is_a_matcher?(thing) &&
      thing.respond_to?(:description)
  end

  private def inspect_anyway(uninspectable)
    "#<uninspectable #{class_of(uninspectable)}>"
  end

  private def class_of(uninspectable)
    uninspectable.class
  rescue NoMethodError
    singleton_class = class << uninspectable; self; end
    singleton_class.ancestors
      .find { |ancestor| !ancestor.equal?(singleton_class) }
  end

  # recursion below

  InspectWrapper = Struct.new(:text) do
    def inspect
      text
    end
  end

  private def recursive_replace_inspect(thing)
    if deja_vu?(thing)
      # I've just been in this place before
      # And I know it's my time to go...
      return InspectWrapper.new(inspect_deja_vu(thing))
    end

    case thing
    when Array
      track_recursion(thing) do
        thing.map { |element| recursive_replace_inspect(element) }
      end
    when Hash
      track_recursion(thing) do
        new_hash = {}

        thing.each do |key, value|
          new_hash[recursive_replace_inspect(key)] = recursive_replace_inspect(value)
        end

        new_hash
      end
    else
      wrap_inspect(thing)
    end
  rescue SystemStackError => e
    wrap_inspect(
      thing,
      text: "#{e.class}: #{e.message}\n\n" \
            "encountered when inspecting #{thing.inspect}"
    )
  end

  private def track_recursion(thing)
    @recursion_trail.push(thing)
    result = yield
    @recursion_trail.pop
    result
  end

  private def deja_vu?(current_place)
    @recursion_trail.any? { |previous_place| previous_place == current_place }
  end

  private def wrap_inspect(thing, text: :_use_diff_inspect)
    text = call(thing) if text == :_use_diff_inspect
    InspectWrapper.new(text)
  end

  # The stdlib inspect code returns this when you have recursive structures.
  STANDARD_INSPECT_RECURSIVE_ARRAY = "[...]".freeze
  STANDARD_INSPECT_RECURSIVE_HASH = "{...}".freeze

  private def inspect_deja_vu(thing)
    case thing
    when Array
      # "#<Array ##{thing.object_id}>"
      STANDARD_INSPECT_RECURSIVE_ARRAY
    when Hash
      # "#<Hash ##{thing.object_id}>"
      STANDARD_INSPECT_RECURSIVE_HASH
    else
      # this should never happen
      raise "Specdiff::Inspect missing deja vu for: #{thing.inspect}"
    end
  end
end
