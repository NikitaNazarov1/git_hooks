# frozen_string_literal: true

require 'fileutils'

module GitHooks
  class Installer # rubocop:disable Metrics/ClassLength
    def initialize(git_dir: nil)
      @git_dir = git_dir || find_git_dir
    end

    def install(*hook_names)
      target_dir = File.join(@git_dir, 'hooks')
      raise GitHooks::Error, "Not a git repository or .git/hooks not found: #{@git_dir}" unless Dir.exist?(target_dir)

      copy_shared_files(target_dir)

      hooks = hook_names.empty? ? Constants::DEFAULT_HOOKS : hook_names
      installed = []

      hooks.each do |name|
        src = File.join(Constants::HOOKS_DIR, name)
        next unless File.file?(src)

        dest = File.join(target_dir, name)
        write_hook(dest, read_template(name))
        make_executable(dest)
        installed << name
      end

      installed
    end

    def self.available_hook_names
      Dir.children(Constants::HOOKS_DIR).select { |f| File.file?(File.join(Constants::HOOKS_DIR, f)) }
    end

    def available_hooks
      self.class.available_hook_names
    end

    def disabled_file_path
      File.join(@git_dir, Constants::DISABLED_FILE)
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

    def enable_whitespace_check
      enable_feature_flag('whitespace-check')
    end

    def disable_whitespace_check
      disable_feature_flag('whitespace-check')
    end

    def whitespace_check_enabled?
      feature_flag_enabled?('whitespace-check')
    end

    def enable_rubocop_check
      enable_feature_flag('rubocop-check')
    end

    def disable_rubocop_check
      disable_feature_flag('rubocop-check')
    end

    def rubocop_check_enabled?
      feature_flag_enabled?('rubocop-check')
    end

    def enable_migrations_check
      # Migrations check is on by default; "disabled" file turns it off.
      file = Constants::FEATURE_FLAG_FILES['migrations-check']
      return unless file

      FileUtils.rm_f(File.join(@git_dir, file))
    end

    def disable_migrations_check
      file = Constants::FEATURE_FLAG_FILES['migrations-check']
      return unless file

      File.write(File.join(@git_dir, file), '')
    end

    def migrations_check_enabled?
      file = Constants::FEATURE_FLAG_FILES['migrations-check']
      file && !File.exist?(File.join(@git_dir, file))
    end

    private

    def enable_feature_flag(name)
      file = Constants::FEATURE_FLAG_FILES[name]
      return unless file

      File.write(File.join(@git_dir, file), '')
    end

    def disable_feature_flag(name)
      file = Constants::FEATURE_FLAG_FILES[name]
      return unless file

      FileUtils.rm_f(File.join(@git_dir, file))
    end

    def feature_flag_enabled?(name)
      file = Constants::FEATURE_FLAG_FILES[name]
      file && File.exist?(File.join(@git_dir, file))
    end

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

    def copy_shared_files(target_dir)
      return unless Dir.exist?(Constants::SHARED_DIR)

      Dir.glob(File.join(Constants::SHARED_DIR, '**', '*')).each do |src|
        next unless File.file?(src)

        rel = src.sub(%r{\A#{Regexp.escape(Constants::SHARED_DIR)}/}, '')
        dest = File.join(target_dir, rel)
        FileUtils.mkdir_p(File.dirname(dest))
        File.write(dest, File.read(src))
      end
    end

    def read_template(name)
      path = File.join(Constants::HOOKS_DIR, name)
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
