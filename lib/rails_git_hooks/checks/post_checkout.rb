# frozen_string_literal: true

module GitHooks
  module Checks
    module PostCheckout
    end
  end
end

require_relative 'post_checkout/bundle_install'
require_relative 'post_checkout/db_migrate'
