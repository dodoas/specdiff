module Specdiff
  Config = Struct.new(:colorize, keyword_init: true) do
    def colorize?
      colorize
    end
  end

  # Read the configuration
  def self.config
    threadlocal[:config] ||= default_configuration
  end

  # private, used for testing
  def self._set_config(new_config)
    threadlocal[:config] = new_config
  end

  # Set the configuration
  def self.configure
    yield(config)
  end

  # Generates the default configuration
  def self.default_configuration
    Config.new(colorize: true)
  end
end
