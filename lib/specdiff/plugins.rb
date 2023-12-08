module Specdiff
  class << self
    attr_reader :plugins
  end
  @plugins = []

  BUILTIN_PLUGINS = %i[json]
  BUILTIN_TYPES = %i[hash array binary text nil]

  # Load extra type support, such as support for json strings
  def self.load!(*plugins)
    return if plugins.size == 0

    plugins.each do |new_plugin|
      if BUILTIN_PLUGINS.include?(new_plugin)
        case new_plugin
        when :json
          require "#{__dir__}/plugins/json"
          load_plugin_class!(::Specdiff::Plugins::Json)
        end
      else
        load_plugin_class!(new_plugin)
      end
    end

    nil
  end

  PLUGIN_INTERFACE = [:id, :detect_type, :compatible?, :diff, :stringify].freeze

  # Load a single plugin class, does not support symbols for builtin plugins.
  def self.load_plugin_class!(plugin)
    plugin_interface = PLUGIN_INTERFACE

    if plugin.respond_to?(:id)
      if BUILTIN_TYPES.include?(plugin.id)
        plugin_interface = PLUGIN_INTERFACE - [:detect_type]
      end

      if plugin.id == :unknown
        raise <<~MSG
          plugin #{plugin.inspect} defined #id to = :unknown, but this is not \
          allowed because it would undermine the utility of the #empty? method \
          on the diff.
        MSG
      end
    end

    missing = plugin_interface.filter do |method_name|
      !plugin.respond_to?(method_name)
    end

    if missing.any?
      raise <<~MSG
        plugin #{plugin.inspect} does not respond to required methods:
        these are required: #{plugin_interface}
        these were missing: #{missing.inspect}
      MSG
    end

    @plugins << plugin
  end

  # private
  def self._clear_plugins!
    @plugins = []
  end

  module Plugins
  end
end
