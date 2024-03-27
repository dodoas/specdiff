class Specdiff::Inspect
  TIME_FORMAT = "%Y-%m-%d %H:%M:%S %z"
  DATE_FORMAT = "%Y-%m-%d"

  def self.call(...)
    new.call(...)
  end

  # #=== allows us to rely on Module implementing #=== instead of relying on the
  # thing (which could be any kind of wacky object) having to implement
  # #is_a? or #kind_of?
  def call(thing)
    if Time === thing
      "#<Time: #{thing.strftime(TIME_FORMAT)}>"
    elsif DateTime === thing
      "#<DateTime: #{thing.rfc3339}>"
    elsif Date === thing
      "#<Date: #{thing.strftime(DATE_FORMAT)}>"
    elsif defined?(BigDecimal) && BigDecimal === thing
      "#<BigDecimal: #{thing.to_s('F')}>"
    else
      begin
        thing.inspect
      rescue NoMethodError
        inspect_anyway(thing)
      end
    end
  end

  private def inspect_anyway(uninspectable)
    "#<#{class_of(uninspectable)}>"
  end

  private def class_of(uninspectable)
    uninspectable.class
  rescue NoMethodError
    singleton_class = class << uninspectable; self; end
    singleton_class.ancestors.find { |ancestor| !ancestor.equal?(singleton_class) }
  end
end
