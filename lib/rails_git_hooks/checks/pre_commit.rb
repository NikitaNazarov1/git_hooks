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
