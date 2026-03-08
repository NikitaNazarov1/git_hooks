# frozen_string_literal: true

require_relative 'rails_git_hooks/version'
require_relative 'rails_git_hooks/constants'
require_relative 'rails_git_hooks/installer'

module GitHooks
  class Error < StandardError; end
end
