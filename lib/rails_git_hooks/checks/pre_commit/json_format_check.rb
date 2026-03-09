# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class JSONFormatCheck < Base
        check_definition key: 'json-format-check',
                         hook: :pre_commit,
                         description: 'Warn on invalid JSON',
                         file_based: true,
                         on_fail: :warn

        def run
          warnings = []

          applicable_files.each do |path|
            next unless File.file?(path)
            next unless File.extname(path) == '.json'

            JSON.parse(File.read(path))
          rescue JSON::ParserError => e
            warnings << "#{path}: #{e.message}"
          end

          warnings.empty? ? CheckResult.pass : CheckResult.fail(messages: warnings)
        end
      end
    end
  end
end
