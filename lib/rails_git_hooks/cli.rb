# frozen_string_literal: true

require 'rails_git_hooks'

module GitHooks
  class CLI
    def self.run(argv = ARGV)
      new.run(argv)
    end

    def run(argv)
      cmd = argv[0].to_s.strip.tr('_', '-')
      case cmd
      when 'install'
        run_install
      when 'init'
        run_init
      when '', '-h', '--help'
        print_help
      else
        warn "Unknown command: #{argv[0]}"
        print_help
        exit 1
      end
    end

    private

    def run_install
      installer = Installer.new
      installed = installer.install
      puts "Installed hooks: #{installed.join(', ')}"
    rescue GitHooks::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    def run_init
      config = OverrideConfig.new(repo: Repository.new)
      config.init
      puts "Initialized #{Constants::CONFIG_FILE}"
    end

    def print_help
      puts <<~HELP
        rails_git_hooks - Install configurable Git hooks

        Usage:
          rails_git_hooks install
          rails_git_hooks init
          rails_git_hooks --help

        Commands:
          install   Install hooks that have at least one enabled check (merged config: defaults + .rails_git_hooks.yml + .rails_git_hooks.local.yml).
          init      Create a sparse #{Constants::CONFIG_FILE} override file.

        Examples:
          rails_git_hooks install
      HELP
    end
  end
end
