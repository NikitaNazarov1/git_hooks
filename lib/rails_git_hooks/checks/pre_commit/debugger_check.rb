# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class DebuggerCheck < Base
        DEBUGGER_PATTERNS = {
          '.rb' => [/\bbinding\.pry\b/, /\bbinding\.irb\b/, /\bdebugger\b/, /\bbyebug\b/],
          '.js' => [/\bdebugger\s*;?/],
          '.jsx' => [/\bdebugger\s*;?/],
          '.ts' => [/\bdebugger\s*;?/],
          '.tsx' => [/\bdebugger\s*;?/],
          '.mjs' => [/\bdebugger\s*;?/],
          '.cjs' => [/\bdebugger\s*;?/],
          '.py' => [/\bbreakpoint\s*\(\s*\)/, /\bpdb\.set_trace\s*\(\s*\)/, /\bipdb\.set_trace\s*\(\s*\)/]
        }.freeze

        check_definition key: 'debugger-check',
                         hook: :pre_commit,
                         description: 'Warn on debugger statements',
                         file_based: true,
                         on_fail: :warn

        def run
          warnings = []

          applicable_files.each do |path|
            next unless File.file?(path)

            patterns = DEBUGGER_PATTERNS[File.extname(path)]
            next unless patterns

            File.read(path).lines.each_with_index do |line, index|
              warnings << "#{path}:#{index + 1}: debugger statement" if patterns.any? { |pattern| line.match?(pattern) }
            end
          end

          warnings.empty? ? CheckResult.pass : CheckResult.fail(messages: warnings.uniq)
        end
      end
    end
  end
end
