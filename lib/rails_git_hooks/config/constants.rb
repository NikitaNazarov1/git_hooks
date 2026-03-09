# frozen_string_literal: true

module GitHooks
  # Paths and default config (single source of truth).
  module Constants
    GEM_ROOT = File.expand_path('../../..', __dir__)
    HOOKS_DIR = File.expand_path('templates/hooks', GEM_ROOT).freeze
    RUNTIME_SOURCE_DIR = File.expand_path('lib/rails_git_hooks', GEM_ROOT).freeze
    RUNTIME_DIR_NAME = 'rails_git_hooks'
    CONFIG_FILE = '.rails_git_hooks.yml'
    CONFIG_FILE_LOCAL = '.rails_git_hooks.local.yml'

    # Default hooks when install is run with no arguments.
    DEFAULT_HOOKS = %w[commit-msg pre-commit].freeze
    HOOK_CONFIG_NAMES = {
      pre_commit: 'PreCommit',
      commit_msg: 'CommitMsg',
      pre_push: 'PrePush'
    }.freeze
  end
end
