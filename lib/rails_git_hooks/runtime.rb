# frozen_string_literal: true

require_relative 'config/constants'
require_relative 'core/error'
require_relative 'core/check_result'
require_relative 'core/check_definition'
require_relative 'runtime/repository'
require_relative 'runtime/file_matcher'
require_relative 'runtime/dependency_checker'
require_relative 'runtime/policy_resolver'
require_relative 'runtime/override_config'
require_relative 'checks'
require_relative 'runtime/check_registry'
require_relative 'runtime/runner'

module GitHooks
  module Runtime
    module_function

    def execute(hook_name, argv: [], stdin: '')
      repo = Repository.new
      Runner.new(repo: repo, hook_name: hook_name, argv: argv, stdin: stdin).run
    end
  end
end
