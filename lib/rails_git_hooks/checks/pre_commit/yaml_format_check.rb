# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class YAMLFormatCheck < Base
        check_definition key: 'yaml-format-check',
                         hook: :pre_commit,
                         description: 'Warn on invalid YAML',
                         file_based: true,
                         on_fail: :warn

        def run
          warnings = []

          applicable_files.each do |path|
            next unless File.file?(path)
            next unless %w[.yml .yaml].include?(File.extname(path))

            YAML.load_file(path)
          rescue Psych::SyntaxError => e
            location = e.line ? "#{path}:#{e.line}" : path
            warnings << "#{location}: #{e.message}"
          end

          warnings.empty? ? CheckResult.pass : CheckResult.fail(messages: warnings)
        end
      end
    end
  end
end
