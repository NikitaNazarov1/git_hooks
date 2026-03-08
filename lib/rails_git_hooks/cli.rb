# frozen_string_literal: true

require 'rails_git_hooks'
require 'yaml'

module GitHooks
  class CLI
    def self.run(argv = ARGV)
      new.run(argv)
    end

    def run(argv)
      case argv[0]
      when 'install'
        run_install(argv[1..])
      when 'list'
        run_list
      when 'init'
        run_init
      when 'disable'
        run_disable(argv[1..])
      when 'enable'
        run_enable(argv[1..])
      when 'set'
        run_set(argv[1..])
      when 'show-config'
        run_show_config
      when nil, '-h', '--help'
        print_help
      else
        warn "Unknown command: #{argv[0]}"
        print_help
        exit 1
      end
    end

    private

    def run_install(args)
      installer = Installer.new
      installed = installer.install(*args)
      puts "Installed hooks: #{installed.join(', ')}"
    rescue GitHooks::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    def run_list
      repo = Repository.new
      config = OverrideConfig.new(repo: repo)

      puts 'Available hooks:'
      Installer.available_hook_names.each { |name| puts "  #{name}" }
      puts
      puts 'Available checks:'
      CheckRegistry.all.each do |definition|
        check_config = config.config_for(definition)
        puts "  #{definition.key} (#{definition.hook_section}/#{definition.config_name}, enabled=#{check_config['enabled']})"
      end
    rescue GitHooks::Error
      puts 'Available hooks:'
      Installer.available_hook_names.each { |name| puts "  #{name}" }
      puts
      puts 'Available checks:'
      CheckRegistry.all.each do |definition|
        puts "  #{definition.key} (#{definition.hook_section}/#{definition.config_name})"
      end
    end

    def run_init
      config = OverrideConfig.new(repo: Repository.new)
      config.init
      puts "Initialized #{Constants::CONFIG_FILE}"
    end

    def run_disable(args)
      key = args.first
      if key.nil?
        warn 'Usage: rails_git_hooks disable CHECK_NAME'
        exit 1
      end

      repo = Repository.new
      definition = CheckRegistry.find!(key)
      OverrideConfig.new(repo: repo).set_option(definition, 'enabled', false)
      puts "Disabled: #{key}"
    end

    def run_enable(args)
      key = args.first
      if key.nil?
        warn 'Usage: rails_git_hooks enable CHECK_NAME'
        exit 1
      end

      repo = Repository.new
      definition = CheckRegistry.find!(key)
      OverrideConfig.new(repo: repo).set_option(definition, 'enabled', true)
      puts "Enabled: #{key}"
    end

    def run_set(args)
      key, option, value = args
      if key.nil? || option.nil? || value.nil?
        warn 'Usage: rails_git_hooks set CHECK_NAME OPTION VALUE'
        exit 1
      end

      definition = CheckRegistry.find!(key)
      OverrideConfig.new(repo: Repository.new).set_option(definition, option, value)
      puts "Updated: #{key} #{option}=#{value}"
    end

    def run_show_config
      repo = Repository.new
      config = OverrideConfig.new(repo: repo).effective_config(CheckRegistry.all)
      puts YAML.dump(config)
    end

    def print_help
      puts <<~HELP
        rails_git_hooks - Install configurable Git hooks

        Usage:
          rails_git_hooks install [HOOK...]
          rails_git_hooks list
          rails_git_hooks init
          rails_git_hooks enable CHECK_NAME
          rails_git_hooks disable CHECK_NAME
          rails_git_hooks set CHECK_NAME OPTION VALUE
          rails_git_hooks show-config
          rails_git_hooks --help

        Commands:
          install   Install hooks into current repo's .git/hooks.
          list      List available hooks and checks.
          init      Create a sparse #{Constants::CONFIG_FILE} override file.
          enable    Enable a check in #{Constants::CONFIG_FILE}.
          disable   Disable a check in #{Constants::CONFIG_FILE}.
          set       Set a check option like on_fail/on_warn/quiet.
          show-config Print effective merged configuration.

        Examples:
          rails_git_hooks install
          rails_git_hooks enable rubocop-check
          rails_git_hooks disable migrations-check
          rails_git_hooks set debugger-check on_fail fail
          rails_git_hooks set rubocop-check quiet true
          rails_git_hooks show-config
          rails_git_hooks install commit-msg pre-commit
      HELP
    end
  end
end
