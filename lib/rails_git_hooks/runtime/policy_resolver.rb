# frozen_string_literal: true

module GitHooks
  class PolicyResolver
    VALID_FAIL_POLICIES = %w[fail warn pass].freeze
    VALID_WARN_POLICIES = %w[warn fail pass].freeze

    def resolve(result, config)
      policy = policy_for(result, config)
      return result if policy == result.status.to_s

      result.with_status(policy.to_sym)
    end

    private

    def policy_for(result, config)
      case result.reason
      when :missing_dependency
        validate(config.fetch('on_missing_dependency', 'warn'), VALID_FAIL_POLICIES)
      else
        case result.status
        when :fail then validate(config.fetch('on_fail', 'fail'), VALID_FAIL_POLICIES)
        when :warn then validate(config.fetch('on_warn', 'warn'), VALID_WARN_POLICIES)
        else 'pass'
        end
      end
    end

    def validate(value, valid_values)
      return value if valid_values.include?(value)

      raise GitHooks::Error, "Invalid policy value: #{value.inspect}"
    end
  end
end
