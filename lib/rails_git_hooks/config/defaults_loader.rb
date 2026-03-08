# frozen_string_literal: true

require 'yaml'

module GitHooks
  class DefaultsLoader
    DEFAULTS_PATH = File.expand_path('defaults.yml', __dir__)

    class << self
      def config_for(hook_section, config_name)
        section = data.fetch(hook_section, {})
        return nil if section.empty?

        section.fetch(config_name, nil)
      end

      private

      def data
        @data ||= load
      end

      def load
        return {} unless File.exist?(DEFAULTS_PATH)

        raw = YAML.safe_load(File.read(DEFAULTS_PATH), aliases: true) || {}
        deep_stringify(raw)
      end

      def deep_stringify(value)
        case value
        when Hash
          value.each_with_object({}) { |(k, v), out| out[k.to_s] = deep_stringify(v) }
        when Array
          value.map { |v| deep_stringify(v) }
        else
          value
        end
      end
    end
  end
end
