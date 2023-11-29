require "json"

class Specdiff::Plugins::Json
  include ::Specdiff::Plugin

  def self.id
    :json
  end

  def self.detect_type(thing)
    thing.is_a?(String) && _json_parsable?(thing)
  end

  def self._json_parsable?(thing)
    return false unless thing.is_a?(String)

    JSON.parse(thing)
    true
  rescue JSON::ParserError
    false
  end

  def self.compatible?(a, b)
    a.type == :json || b.type == :json
  end

  def self.diff(a, b)
    a_value = a.value
    b_value = b.value

    a_value = JSON.parse(a_value) if a.type == :json
    b_value = JSON.parse(b_value) if b.type == :json

    ::Specdiff.diff(a_value, b_value)
  end

  def self.stringify(_diff)
    # since we recurse back into Specdiff, we don't need to stringify in this
    # plugin. the built in hash/array/text differs should do the stringification
    raise "#{self.class}::stringify was called, this should never happen"
  end
end
