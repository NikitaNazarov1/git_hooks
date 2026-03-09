# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class WhitespaceCheck < Base
        check_definition key: 'whitespace-check',
                         hook: :pre_commit,
                         description: 'Reject trailing whitespace and conflict markers',
                         file_based: true,
                         enabled: false

        def run
          errors = []

          applicable_files.each do |path|
            next unless File.file?(path)

            File.read(path).lines.each_with_index do |line, index|
              errors << "#{path}:#{index + 1}: trailing whitespace" if line.match?(/[ \t]\z/)
              stripped = line.strip
              errors << "#{path}:#{index + 1}: conflict marker" if stripped.start_with?('<<<<<<<', '=======', '>>>>>>>')
            end
          end

          errors.empty? ? CheckResult.pass : CheckResult.fail(messages: errors.uniq)
        end
      end
    end
  end
end
