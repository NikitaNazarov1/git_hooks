# frozen_string_literal: true

module GitHooks
  module Checks
    module PreCommit
    end
  end
end

require_relative 'pre_commit/default_branch'
require_relative 'pre_commit/debugger_check'
require_relative 'pre_commit/yaml_format_check'
require_relative 'pre_commit/json_format_check'
require_relative 'pre_commit/migrations_check'
require_relative 'pre_commit/whitespace_check'
require_relative 'pre_commit/rubocop'
require_relative 'pre_commit/rails_best_practices'
require_relative 'pre_commit/erblint'
require_relative 'pre_commit/eslint'
require_relative 'pre_commit/golint'
require_relative 'pre_commit/haml_lint'
require_relative 'pre_commit/jslint'
require_relative 'pre_commit/php_lint'
require_relative 'pre_commit/pylint'
require_relative 'pre_commit/scss_lint'
require_relative 'pre_commit/go_vet'
