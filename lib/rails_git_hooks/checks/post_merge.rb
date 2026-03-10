# frozen_string_literal: true

module GitHooks
  module Checks
    module PostMerge
    end
  end
end

require_relative 'post_merge/bundle_install'
require_relative 'post_merge/db_migrate'
require_relative 'post_merge/npm_install'
require_relative 'post_merge/yarn_install'
