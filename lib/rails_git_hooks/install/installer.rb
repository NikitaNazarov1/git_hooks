# frozen_string_literal: true

require 'fileutils'

module GitHooks
  class Installer
    def initialize(git_dir: nil)
      @git_dir = git_dir || Repository.new.git_dir
    end

    def install(*hook_names)
      target_dir = File.join(@git_dir, 'hooks')
      raise GitHooks::Error, "Not a git repository or .git/hooks not found: #{@git_dir}" unless Dir.exist?(target_dir)

      copy_runtime(target_dir)

      hooks = hook_names.empty? ? Constants::DEFAULT_HOOKS : hook_names
      hooks.each_with_object([]) do |name, installed|
        next unless self.class.available_hook_names.include?(name)

        dest = File.join(target_dir, name)
        File.write(dest, File.read(File.join(Constants::HOOKS_DIR, name)))
        File.chmod(0o755, dest)
        installed << name
      end
    end

    def self.available_hook_names
      Dir.children(Constants::HOOKS_DIR).select { |name| File.file?(File.join(Constants::HOOKS_DIR, name)) }
    end

    def available_hooks
      self.class.available_hook_names
    end

    private

    def copy_runtime(target_dir)
      runtime_dir = File.join(target_dir, Constants::RUNTIME_DIR_NAME)
      FileUtils.rm_rf(runtime_dir)
      FileUtils.mkdir_p(runtime_dir)

      Dir.glob(File.join(Constants::RUNTIME_SOURCE_DIR, '**', '*')).each do |src|
        next unless File.file?(src)

        rel = src.sub(%r{\A#{Regexp.escape(Constants::RUNTIME_SOURCE_DIR)}/}, '')
        dest = File.join(runtime_dir, rel)
        FileUtils.mkdir_p(File.dirname(dest))
        File.write(dest, File.read(src))
      end
    end
  end
end
