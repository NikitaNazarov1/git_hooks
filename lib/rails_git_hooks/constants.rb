# frozen_string_literal: true

module GitHooks
  # Paths and default config (single source of truth).
  module Constants
    GEM_ROOT = File.expand_path('../..', __dir__)
    HOOKS_DIR = File.expand_path('templates/hooks', GEM_ROOT).freeze
    SHARED_DIR = File.expand_path('templates/shared', GEM_ROOT).freeze

    DISABLED_FILE = 'rails_git_hooks_disabled'

    # Default hooks when install is run with no arguments.
    DEFAULT_HOOKS = %w[commit-msg pre-commit].freeze

    # Pre-commit feature flag file names (keys = CLI tokens).
    FEATURE_FLAG_FILES = {
      'whitespace-check' => 'rails_git_hooks_whitespace_check',
      'rubocop-check' => 'rails_git_hooks_rubocop'
    }.freeze
  end
end
