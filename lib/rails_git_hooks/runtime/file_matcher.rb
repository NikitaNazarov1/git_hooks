# frozen_string_literal: true

module GitHooks
  module FileMatcher
    FLAGS = File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB

    module_function

    def filter(paths, include_patterns:, exclude_patterns:)
      filtered = if include_patterns.empty?
                   paths
                 else
                   paths.select { |path| matches_any?(path, include_patterns) }
                 end

      filtered.reject { |path| matches_any?(path, exclude_patterns) }
    end

    def matches_any?(path, patterns)
      Array(patterns).any? { |pattern| File.fnmatch?(pattern, path, FLAGS) }
    end
  end
end
