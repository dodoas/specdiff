module Specdiff
  Config = Struct.new(:colorize, keyword_init: true) do
    def colorize?
      colorize
    end
  end

  class << self
    attr_reader :config
  end

  # Generates the default configuration
  def self.default_configuration
    config = Config.new(colorize: true)

    if !ENV["NO_COLOR"].nil? && !ENV["NO_COLOR"].empty?
      config.colorize = false
    else
      config.colorize = $stdout.isatty
    end

    config.freeze
  end

  @config = default_configuration.dup

  # private, used for testing
  def self._set_config(new_config)
    @config = new_config
  end

  # Set the configuration
  def self.configure
    yield(@config)
    @config
  end
end
