# frozen_string_literal: true

require 'rails_git_hooks'
require 'optparse'

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
      jira = nil
      OptionParser.new do |opts|
        opts.on('--jira PROJECT', 'Jira project key (e.g. APD)') { |v| jira = v }
      end.parse!(args)
      hooks = args

      installer = Installer.new(jira_project: jira)
      installed = installer.install(*hooks)
      puts "Installed hooks: #{installed.join(', ')}"
    rescue GitHooks::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    def run_list
      dir = GitHooks::Installer::HOOKS_DIR
      hooks = Dir.children(dir).select { |f| File.file?(File.join(dir, f)) }
      puts "Available hooks: #{hooks.join(', ')}"
    end

    def run_disable(args)
      hooks = args.reject { |a| a.start_with?('-') }
      if hooks.empty?
        warn 'Usage: rails_git_hooks disable HOOK [HOOK...]'
        warn "Use '*' to disable all hooks."
        exit 1
      end
      installer = Installer.new
      installer.disable(*hooks)
      puts "Disabled: #{hooks.join(', ')}"
    rescue GitHooks::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    def run_enable(args)
      hooks = args.reject { |a| a.start_with?('-') }
      if hooks.empty?
        warn 'Usage: rails_git_hooks enable HOOK [HOOK...]'
        exit 1
      end
      installer = Installer.new
      installer.enable(*hooks)
      puts "Enabled: #{hooks.join(', ')}"
    rescue GitHooks::Error => e
      warn "Error: #{e.message}"
      exit 1
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
          rails_git_hooks install [HOOK...] [--jira PROJECT_KEY]
          rails_git_hooks disable HOOK [HOOK...]   (use * for all)
          rails_git_hooks enable HOOK [HOOK...]
          rails_git_hooks disabled
          rails_git_hooks list
          rails_git_hooks --help

        Commands:
          install    Install hooks into current repo's .git/hooks.
          disable    Disable hooks (they no-op until enabled).
          enable     Re-enable disabled hooks.
          disabled   List currently disabled hooks.
          list       List available hook names.

        Examples:
          rails_git_hooks install
          rails_git_hooks disable pre-commit
          rails_git_hooks disable *              # disable all
          rails_git_hooks enable pre-commit
          rails_git_hooks install commit-msg pre-commit --jira MYPROJ
      HELP
    end
  end
end
