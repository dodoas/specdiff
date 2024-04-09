# Tries to print nested hash/array structures such that they are as convenient
# as possible for a diffing algorithm designed for text (like source code).
# Basically tries to reproduce consistent literal source code form for ruby
# hashes and arrays and objects (although it falls back to #inspect).
class Specdiff::Hashprint
  def self.call(...)
    new.call(...)
  end

  INDENTATION_SPACES = 2
  SPACE = " ".freeze
  COMMA = ",".freeze
  NEWLINE = "\n".freeze

  def call(thing)
    @recursion_trail = []
    @indentation_level = 0
    @indentation_per_level = SPACE * INDENTATION_SPACES
    @indent = ""
    @skip_next_opening_indent = false

    @output = StringIO.new

    output(thing)

    @output.string
  end

private

  def recalculate_indent
    @indent = @indentation_per_level * @indentation_level
  end

  def increase_indentation
    @indentation_level += 1
    recalculate_indent
  end

  def decrease_indentation
    @indentation_level -= 1
    recalculate_indent
  end

  def skip_next_opening_indent
    @skip_next_opening_indent = true

    nil
  end

  def this_indent_should_be_skipped
    if @skip_next_opening_indent
      @skip_next_opening_indent = false
      true
    else
      false
    end
  end

  def track_recursion(thing)
    @recursion_trail.push(thing)
    result = yield
    @recursion_trail.pop
    result
  end

  def deja_vu?(current_place)
    @recursion_trail.any? { |previous_place| previous_place == current_place }
  end

  # #=== allows us to rely on Module implementing #=== instead of relying on the
  # thing (which could be any kind of wacky object) having to implement
  # #is_a? or #kind_of?
  def output(thing)
    if deja_vu?(thing)
      output_deja_vu(thing)
    elsif Hash === thing
      output_hash(thing)
    elsif Array === thing
      output_array(thing)
    else
      output_unknown(thing)
    end
  end

  HASH_OPEN = "{".freeze
  HASH_CLOSE = "}".freeze
  HASHROCKET = "=>".freeze
  COLON = ":".freeze

  def output_hash(hash)
    @output << @indent unless this_indent_should_be_skipped

    @output << HASH_OPEN
    @output << NEWLINE

    increase_indentation
    track_recursion(hash) do
      try_to_sort(hash)
        .each do |key, value|
          @output << @indent

          if key.is_a?(Symbol)
            @output << key
            @output << COLON
            @output << SPACE
          else
            @output << ::Specdiff.diff_inspect(key)
            @output << SPACE
            @output << HASHROCKET
            @output << SPACE
          end

          skip_next_opening_indent
          output(value)

          @output << COMMA
          @output << NEWLINE
        end
    end
    decrease_indentation

    @output << @indent
    @output << HASH_CLOSE
  end

  def try_to_sort(hash)
    return hash unless hash.keys.all? { |k| String === k || Symbol === k }

    hash.sort_by { |k, _v| k.to_s }
  end

  ARRAY_OPEN = "[".freeze
  ARRAY_CLOSE = "]".freeze

  def output_array(array)
    @output << @indent unless this_indent_should_be_skipped

    @output << ARRAY_OPEN
    @output << NEWLINE

    increase_indentation
    track_recursion(array) do
      array.each do |element|
        output(element)
        @output << COMMA
        @output << NEWLINE
      end
    end
    decrease_indentation

    @output << @indent
    @output << ARRAY_CLOSE
  end

  def output_unknown(thing)
    @output << @indent unless this_indent_should_be_skipped

    @output << ::Specdiff.diff_inspect(thing)
  end

  # The stdlib inspect code returns this when you have recursive structures.
  STANDARD_INSPECT_RECURSIVE_ARRAY = "[...]".freeze
  STANDARD_INSPECT_RECURSIVE_HASH = "{...}".freeze

  def output_deja_vu(thing)
    @output << @indent unless this_indent_should_be_skipped

    case thing
    when Array
      # "#<Array ##{thing.object_id}>"
      @output << STANDARD_INSPECT_RECURSIVE_ARRAY
    when Hash
      # "#<Hash ##{thing.object_id}>"
      @output << STANDARD_INSPECT_RECURSIVE_HASH
    else
      # this should never happen
      raise "Specdiff::Hashprint missing deja vu for: #{thing.inspect}"
    end
  end
end
