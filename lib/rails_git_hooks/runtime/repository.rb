# frozen_string_literal: true

require 'open3'

module GitHooks
  class Repository
    attr_reader :root, :git_dir

    def initialize(start_dir = Dir.pwd)
      @root, @git_dir = resolve_paths(start_dir)
    end

    def config_path
      File.join(root, Constants::CONFIG_FILE)
    end

    def local_config_path
      File.join(root, Constants::CONFIG_FILE_LOCAL)
    end

    def hook_runtime_dir(hooks_dir)
      File.join(hooks_dir, Constants::RUNTIME_DIR_NAME)
    end

    def git(*args)
      stdout, status = Open3.capture2e('git', *args, chdir: root)
      [stdout, status]
    end

    def git_output(*args)
      stdout, status = git(*args)
      raise GitHooks::Error, stdout.strip unless status.success?

      stdout
    end

    def current_branch
      git_output('rev-parse', '--abbrev-ref', 'HEAD').strip
    end

    def staged_files
      git_output('diff', '--cached', '--name-only').split("\n").map(&:strip).reject(&:empty?)
    end

    def changed_files(ref1, ref2)
      git_output('diff', '--name-only', ref1.to_s, ref2.to_s).split("\n").map(&:strip).reject(&:empty?)
    end

    private

    def resolve_paths(start_dir)
      dir = File.expand_path(start_dir)
      loop do
        git_entry = File.join(dir, '.git')
        if File.directory?(git_entry)
          return [dir, git_entry]
        elsif File.file?(git_entry)
          git_dir = File.expand_path(File.read(git_entry).strip.sub(/\Agitdir: \s*/, ''), dir)
          return [dir, git_dir]
        end

        parent = File.dirname(dir)
        raise GitHooks::Error, 'Not inside a git repository' if parent == dir

        dir = parent
      end
    end
  end
end
