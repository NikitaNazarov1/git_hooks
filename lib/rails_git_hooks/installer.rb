# frozen_string_literal: true

module GitHooks
  class Installer
    HOOKS_DIR = File.expand_path('templates', __dir__).freeze

    def initialize(git_dir: nil, jira_project: nil)
      @git_dir = git_dir || find_git_dir
      @jira_project = jira_project || ENV['GIT_HOOKS_JIRA_PROJECT'] || 'APD'
    end

    def install(*hook_names)
      target_dir = File.join(@git_dir, 'hooks')
      raise GitHooks::Error, "Not a git repository or .git/hooks not found: #{@git_dir}" unless Dir.exist?(target_dir)

      hooks = hook_names.empty? ? available_hooks : hook_names
      installed = []

      hooks.each do |name|
        src = File.join(HOOKS_DIR, name)
        next unless File.file?(src)

        dest = File.join(target_dir, name)
        content = read_template(name)
        content = content.gsub('JIRA_PROJECT_KEY', @jira_project) if name == 'commit-msg'
        write_hook(dest, content)
        make_executable(dest)
        installed << name
      end

      installed
    end

    def available_hooks
      Dir.children(HOOKS_DIR).select { |f| File.file?(File.join(HOOKS_DIR, f)) }
    end

    DISABLED_FILE = 'rails_git_hooks_disabled'

    def disabled_file_path
      File.join(@git_dir, DISABLED_FILE)
    end

    def disabled_hooks
      path = disabled_file_path
      return [] unless File.exist?(path)

      File.read(path).split("\n").map(&:strip).reject(&:empty?)
    end

    def disable(*hook_names)
      path = disabled_file_path
      current = (disabled_hooks + hook_names).uniq
      File.write(path, "#{current.join("\n")}\n")
      hook_names
    end

    def enable(*hook_names)
      path = disabled_file_path
      return [] unless File.exist?(path)

      current = disabled_hooks - hook_names
      if current.empty?
        File.delete(path)
      else
        File.write(path, "#{current.join("\n")}\n")
      end
      hook_names
    end

    private

    def find_git_dir
      dir = Dir.pwd
      loop do
        git = File.join(dir, '.git')
        return git if File.directory?(git)

        parent = File.dirname(dir)
        raise GitHooks::Error, 'Not inside a git repository' if parent == dir

        dir = parent
      end
    end

    def read_template(name)
      path = File.join(HOOKS_DIR, name)
      File.read(path)
    end

    def write_hook(path, content)
      File.write(path, content)
    end

    def make_executable(path)
      File.chmod(0o755, path)
    end
  end
end
