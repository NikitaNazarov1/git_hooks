# frozen_string_literal: true

require 'json'
require 'open3'
require 'yaml'

module GitHooks
  module Checks
    class Base
      class << self
        attr_reader :definition

        def check_definition(key:, hook:, description:, config_name: name.split('::').last, **options)
          @definition = CheckDefinition.new(
            key: key,
            config_name: config_name,
            hook: hook,
            klass: self,
            description: description,
            **options
          )
        end
      end

      attr_reader :config, :context

      def initialize(config:, context:)
        @config = config
        @context = context
      end

      private

      def repo
        context.fetch(:repo)
      end

      def applicable_files
        context.fetch(:applicable_files, [])
      end

      def argv
        context.fetch(:argv, [])
      end

      def stdin
        context.fetch(:stdin, '')
      end

      def capture(*command)
        Open3.capture2e(*command, chdir: repo.root)
      end
    end
  end
end
