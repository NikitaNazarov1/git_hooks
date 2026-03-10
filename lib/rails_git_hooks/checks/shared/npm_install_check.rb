# frozen_string_literal: true

module GitHooks
  module Checks
    # Shared logic and options for "run npm install when package.json/package-lock.json changed"
    # (post-checkout and post-merge). Each hook has its own class that passes hook + description.
    module NpmInstallCheck
      DEFINITION_OPTIONS = {
        file_based: true,
        enabled: false,
        include: %w[package.json package-lock.json],
        dependencies: { executables: ['npm'] },
        command: %w[npm install],
        install_hint: 'Ensure npm is available'
      }.freeze

      def run
        return CheckResult.pass if applicable_files.empty?

        output, status = capture(*Array(config['command']))
        return CheckResult.pass if status.success?

        messages = output.split("\n").map(&:rstrip).reject(&:empty?)
        CheckResult.fail(messages: messages)
      end
    end
  end
end
