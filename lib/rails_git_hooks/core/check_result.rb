# frozen_string_literal: true

module GitHooks
  class CheckResult
    attr_reader :status, :messages, :reason

    def initialize(status:, messages: [], reason: nil)
      @status = status.to_sym
      @messages = Array(messages).compact
      @reason = reason&.to_sym
    end

    def self.pass(messages: [])
      new(status: :pass, messages: messages, reason: :pass)
    end

    def self.warn(messages:, reason: :warning)
      new(status: :warn, messages: messages, reason: reason)
    end

    def self.fail(messages:, reason: :failure)
      new(status: :fail, messages: messages, reason: reason)
    end

    def with_status(status)
      self.class.new(status: status, messages: messages, reason: reason)
    end

    def pass?
      status == :pass
    end

    def warn?
      status == :warn
    end

    def fail?
      status == :fail
    end
  end
end
