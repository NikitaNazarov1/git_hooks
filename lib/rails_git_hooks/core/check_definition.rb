# frozen_string_literal: true

module GitHooks
  class CheckDefinition
    DEFAULTS = {
      enabled: true,
      quiet: false,
      on_fail: :fail,
      on_warn: :warn,
      on_missing_dependency: :warn,
      include: [],
      exclude: [],
      dependencies: {},
      command: nil,
      file_based: false
    }.freeze

    attr_reader :key, :config_name, :hook, :klass, :description

    def initialize(key:, config_name:, hook:, klass:, description:, **options)
      @key = key
      @config_name = config_name
      @hook = hook
      @klass = klass
      @description = description
      @options = DEFAULTS.merge(options)
    end

    def default_config
      {
        'enabled' => @options[:enabled],
        'quiet' => @options[:quiet],
        'on_fail' => @options[:on_fail].to_s,
        'on_warn' => @options[:on_warn].to_s,
        'on_missing_dependency' => @options[:on_missing_dependency].to_s,
        'include' => Array(@options[:include]),
        'exclude' => Array(@options[:exclude]),
        'dependencies' => deep_stringify(@options[:dependencies]),
        'command' => Array(@options[:command]).compact,
        'description' => description,
        'file_based' => @options[:file_based],
        'install_hint' => @options[:install_hint]
      }.compact
    end

    def hook_section
      Constants::HOOK_CONFIG_NAMES.fetch(hook)
    end

    private

    def deep_stringify(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, nested), out| out[key.to_s] = deep_stringify(nested) }
      when Array
        value.map { |nested| deep_stringify(nested) }
      else
        value
      end
    end
  end
end
