# frozen_string_literal: true

require 'git_hooks'

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
      hooks = []
      i = 0
      while i < args.size
        case args[i]
        when '--jira'
          jira = args[i + 1]
          i += 2
          next
        when /^--/
          i += 1
          next
        else
          hooks << args[i]
        end
        i += 1
      end

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
        warn 'Usage: git_hooks disable HOOK [HOOK...]'
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
        warn 'Usage: git_hooks enable HOOK [HOOK...]'
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
        git_hooks - Install git hooks for Jira commit prefix and RuboCop

        Usage:
          git_hooks install [HOOK...] [--jira PROJECT_KEY]
          git_hooks disable HOOK [HOOK...]   (use * for all)
          git_hooks enable HOOK [HOOK...]
          git_hooks disabled
          git_hooks list
          git_hooks --help

        Commands:
          install    Install hooks into current repo's .git/hooks.
          disable    Disable hooks (they no-op until enabled).
          enable     Re-enable disabled hooks.
          disabled   List currently disabled hooks.
          list       List available hook names.

        Examples:
          git_hooks install
          git_hooks disable pre-commit
          git_hooks disable *              # disable all
          git_hooks enable pre-commit
          git_hooks install commit-msg pre-commit --jira MYPROJ
      HELP
    end
  end
end
