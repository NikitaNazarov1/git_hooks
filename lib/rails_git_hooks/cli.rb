# frozen_string_literal: true

require 'rails_git_hooks'

module GitHooks
  class CLI
    FEATURE_FLAG_TOKENS = GitHooks::Constants::FEATURE_FLAG_FILES.keys.freeze

    def self.run(argv = ARGV)
      new.run(argv)
    end

    def run(argv)
      case argv[0]
      when 'install'
        run_install(argv[1..])
      when 'list'
        run_list
      when 'disable'
        run_disable(argv[1..])
      when 'enable'
        run_enable(argv[1..])
      when 'disabled'
        run_disabled
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
      puts "Available hooks: #{Installer.available_hook_names.join(', ')}"
    end

    def run_disable(args)
      tokens = parse_tokens(args)
      if tokens.empty?
        warn 'Usage: rails_git_hooks disable HOOK [HOOK...] [whitespace-check] [rubocop-check] [migrations-check]'
        warn "Use '*' to disable all hooks."
        exit 1
      end
      installer = Installer.new
      hook_names, feature_flags = split_tokens(tokens)
      feature_flags.each { |name| installer.public_send(:"disable_#{name.tr('-', '_')}") }
      installer.disable(*hook_names) if hook_names.any?
      puts "Disabled: #{(hook_names + feature_flags).join(', ')}"
    rescue GitHooks::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    def run_enable(args)
      tokens = parse_tokens(args)
      if tokens.empty?
        warn 'Usage: rails_git_hooks enable HOOK [HOOK...] [whitespace-check] [rubocop-check] [migrations-check]'
        exit 1
      end
      installer = Installer.new
      hook_names, feature_flags = split_tokens(tokens)
      feature_flags.each { |name| installer.public_send(:"enable_#{name.tr('-', '_')}") }
      installer.enable(*hook_names) if hook_names.any?
      puts "Enabled: #{(hook_names + feature_flags).join(', ')}"
    rescue GitHooks::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    def parse_tokens(args)
      args.reject { |a| a.start_with?('-') }
    end

    def split_tokens(tokens)
      feature_flags = tokens & FEATURE_FLAG_TOKENS
      hook_names = tokens - FEATURE_FLAG_TOKENS
      [hook_names, feature_flags]
    end

    def run_disabled
      installer = Installer.new
      list = installer.disabled_hooks
      if list.empty?
        puts 'No hooks disabled.'
      else
        puts "Disabled hooks: #{list.join(', ')}"
      end
    rescue GitHooks::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    def print_help
      puts <<~HELP
        rails_git_hooks - Install git hooks for Jira commit prefix and RuboCop

        Usage:
          rails_git_hooks install [HOOK...]
          rails_git_hooks disable HOOK [HOOK...] [whitespace-check] [rubocop-check] [migrations-check]   (use * for all hooks)
          rails_git_hooks enable HOOK [HOOK...] [whitespace-check] [rubocop-check] [migrations-check]
          rails_git_hooks disabled
          rails_git_hooks list
          rails_git_hooks --help

        Commands:
          install   Install hooks into current repo's .git/hooks.
          disable   Disable hooks or whitespace-check / rubocop-check / migrations-check (pre-commit options).
          enable    Re-enable disabled hooks or enable whitespace-check / rubocop-check / migrations-check.
          disabled  List currently disabled hooks.
          list      List available hook names.

        Examples:
          rails_git_hooks install
          rails_git_hooks disable pre-commit
          rails_git_hooks disable *                    # disable all hooks
          rails_git_hooks enable pre-commit
          rails_git_hooks enable whitespace-check      # trailing ws/conflict markers (off by default)
          rails_git_hooks enable rubocop-check         # RuboCop on staged .rb files (off by default)
          rails_git_hooks disable migrations-check     # turn off migrations check (on by default)
          rails_git_hooks install commit-msg pre-commit
      HELP
    end
  end
end
