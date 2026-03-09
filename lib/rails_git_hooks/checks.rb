# frozen_string_literal: true

require_relative 'checks/base'
require_relative 'checks/pre_commit'
require_relative 'checks/commit_msg'
require_relative 'checks/pre_push'
require_relative 'checks/shared/bundle_install_check'
require_relative 'checks/shared/db_migrate_check'
require_relative 'checks/post_checkout'
require_relative 'checks/post_merge'
