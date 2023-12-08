module Specdiff
  Config = Struct.new(:colorize, keyword_init: true) do
    def colorize?
      colorize
    end
  end

  class << self
    attr_reader :config
  end

  DEFAULT = Config.new(colorize: true).freeze
  @config = DEFAULT.dup

  # private, used for testing
  def self._set_config(new_config)
    @config = new_config
  end

  # Set the configuration
  def self.configure
    yield(@config)
    @config
  end

  # Generates the default configuration
  def self.default_configuration
    DEFAULT
  end
end
