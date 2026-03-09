# frozen_string_literal: true

require 'fileutils'
require 'yaml'

require_relative '../config/defaults_loader'

module GitHooks
  class OverrideConfig
    BOOLEAN_OPTIONS = %w[enabled quiet].freeze
    POLICY_OPTIONS = %w[on_fail on_warn on_missing_dependency].freeze

    def initialize(repo:)
      @repo = repo
    end

    def load
      main = load_file(@repo.config_path)
      local = load_file(@repo.local_config_path)
      deep_merge(main, local)
    end

    def config_for(definition)
      base = DefaultsLoader.config_for(definition.hook_section, definition.config_name) || definition.default_config
      data = load
      section = data.fetch(definition.hook_section, {})
      merged = deep_merge(base, section.fetch('ALL', {}))
      deep_merge(merged, section.fetch(definition.config_name, {}))
    end

    def effective_config(registry)
      registry.group_by(&:hook_section).transform_values do |definitions|
        definitions.to_h { |definition| [definition.config_name, config_for(definition)] }
      end
    end

    def set_option(definition, option, value)
      data = load_file(@repo.config_path)
      section = data[definition.hook_section] ||= {}
      section[definition.config_name] ||= {}

      normalized = normalize_value(option, value)
      base = DefaultsLoader.config_for(definition.hook_section, definition.config_name) || definition.default_config
      default_value = base[option]

      if normalized == default_value
        section[definition.config_name].delete(option)
      else
        section[definition.config_name][option] = normalized
      end

      cleanup_empty_nodes!(data, definition)
      write(data)
    end

    def init
      return if File.exist?(@repo.config_path)

      File.write(@repo.config_path, <<~YAML)
        # rails_git_hooks overrides
        #
        # Example:
        # PreCommit:
        #   RuboCop:
        #     enabled: true
        #     on_fail: fail
      YAML
    end

    private

    def load_file(path)
      return {} unless File.exist?(path)

      deep_stringify(YAML.safe_load(File.read(path), aliases: true) || {})
    end

    def write(data)
      if data.empty?
        FileUtils.rm_f(@repo.config_path)
      else
        File.write(@repo.config_path, YAML.dump(data))
      end
    end

    def cleanup_empty_nodes!(data, definition)
      section = data.fetch(definition.hook_section, {})
      section.delete(definition.config_name) if section.fetch(definition.config_name, {}).empty?
      data.delete(definition.hook_section) if section.empty?
    end

    def normalize_value(option, value)
      case option
      when *BOOLEAN_OPTIONS
        parse_boolean(value)
      when *POLICY_OPTIONS
        value.to_s
      else
        value
      end
    end

    def parse_boolean(value)
      return value if [true, false].include?(value)

      case value.to_s
      when 'true', 'yes', 'on', '1' then true
      when 'false', 'no', 'off', '0' then false
      else
        raise GitHooks::Error, "Invalid boolean value: #{value.inspect}"
      end
    end

    def deep_merge(base, override)
      base.merge(override) do |_key, old, new|
        old.is_a?(Hash) && new.is_a?(Hash) ? deep_merge(old, new) : new
      end
    end

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
