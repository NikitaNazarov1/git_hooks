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
      Checks::PreCommit::RailsBestPractices,
      Checks::CommitMsg::JiraPrefix,
      Checks::CommitMsg::NotEmpty,
      Checks::PrePush::RunTests,
      Checks::PostCheckout::BundleInstall,
      Checks::PostCheckout::DbMigrate,
      Checks::PostCheckout::NpmInstall,
      Checks::PostCheckout::YarnInstall,
      Checks::PostMerge::BundleInstall,
      Checks::PostMerge::DbMigrate,
      Checks::PostMerge::NpmInstall,
      Checks::PostMerge::YarnInstall
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
