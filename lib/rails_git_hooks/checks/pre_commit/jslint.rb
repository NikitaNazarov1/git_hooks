# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
      class Jslint < Base
        JS_EXTENSIONS = %w[.js .jsx .mjs .cjs].freeze

        check_definition key: 'jslint-check',
                         hook: :pre_commit,
                         description: 'Run jslint on staged JavaScript files',
                         file_based: true,
                         enabled: false,
                         quiet: true,
                         dependencies: { 'executables' => ['jslint'] },
                         command: %w[jslint],
                         install_hint: 'Install jslint or override command in config'

        def run
          js_files = applicable_files.select do |path|
            File.file?(path) && JS_EXTENSIONS.include?(File.extname(path))
          end
          return CheckResult.pass if js_files.empty?

          output, status = capture(*Array(config['command']), *js_files)
          return CheckResult.pass if status.success?

          messages = output.split("\n").map(&:rstrip).reject(&:empty?)
          CheckResult.fail(messages: messages)
        end
      end
    end
  end
end
