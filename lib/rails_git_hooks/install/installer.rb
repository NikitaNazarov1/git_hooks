# frozen_string_literal: true

require 'fileutils'

module GitHooks
  class Installer
    def initialize(git_dir: nil)
      if git_dir
        @git_dir = git_dir
        @repo = nil
      else
        @repo = Repository.new
        @git_dir = @repo.git_dir
      end
    end

    def install
      target_dir = File.join(@git_dir, 'hooks')
      raise GitHooks::Error, "Not a git repository or .git/hooks not found: #{@git_dir}" unless Dir.exist?(target_dir)

      copy_runtime(target_dir)

      hooks = hooks_enabled_in_config.select { |name| self.class.available_hook_names.include?(name) }
      hooks.each_with_object([]) do |name, installed|
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

    def repo_for_config
      @repo_for_config ||= begin
        root = File.dirname(@git_dir)
        Struct.new(:root, :config_path, :local_config_path).new(
          root,
          File.join(root, Constants::CONFIG_FILE),
          File.join(root, Constants::CONFIG_FILE_LOCAL)
        )
      end
    end

    def hooks_enabled_in_config
      override_config = OverrideConfig.new(repo: repo_for_config)
      effective = override_config.effective_config(CheckRegistry.all)
      effective.each_with_object([]) do |(section_name, check_configs), out|
        hook_name = Constants::SECTION_TO_HOOK[section_name]
        next unless hook_name && self.class.available_hook_names.include?(hook_name)

        out << hook_name if check_configs.values.any? { |cfg| cfg['enabled'] == true }
      end.uniq
    end

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
