# frozen_string_literal: true

module GitHooks
  class CheckRegistry
    CHECK_CLASSES = [
      Checks::PreCommit::DefaultBranch,
      Checks::PreCommit::DebuggerCheck,
      Checks::PreCommit::YAMLFormatCheck,
      Checks::PreCommit::JSONFormatCheck,
      Checks::PreCommit::MigrationsCheck,
      Checks::PreCommit::WhitespaceCheck,
      Checks::PreCommit::RuboCop,
      Checks::CommitMsg::JiraPrefix,
      Checks::PrePush::RunTests
    ].freeze

    def self.all
      CHECK_CLASSES.map(&:definition)
    end

    def self.for(hook_name)
      all.select { |definition| definition.hook == hook_name.to_sym }
    end

    def self.find!(key)
      all.find { |definition| definition.key == key } || raise(GitHooks::Error, "Unknown check: #{key}")
    end
  end
end
