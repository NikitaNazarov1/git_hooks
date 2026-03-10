# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'tmpdir'

RSpec.describe GitHooks::Checks::PreCommit::RailsBestPractices do
  let(:config) { described_class.definition.default_config.merge('command' => %w[bundle exec rails_best_practices]) }
  let(:repo_root) { Dir.mktmpdir('rails_best_practices_spec') }
  let(:repo) { instance_double(GitHooks::Repository, root: repo_root) }
  let(:context) { { repo: repo, applicable_files: files, argv: [], stdin: '' } }

  after { FileUtils.rm_rf(repo_root) }

  describe '#run' do
    context 'when no Ruby files in applicable_files' do
      let(:files) { ['config/settings.yml'] }

      it 'returns pass without running command' do
        check = described_class.new(config: config, context: context)
        expect(Open3).not_to receive(:capture2e)
        expect(check.run).to be_pass
      end
    end

    context 'when command succeeds' do
      let(:ruby_path) { File.join(repo_root, 'app/models/user.rb') }
      let(:files) { [ruby_path] }

      before do
        FileUtils.mkdir_p(File.dirname(ruby_path))
        File.write(ruby_path, 'class User; end')
        allow(Open3).to receive(:capture2e).and_return(['', double(success?: true)])
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when command fails' do
      let(:ruby_path) { File.join(repo_root, 'app/controllers/foo_controller.rb') }
      let(:files) { [ruby_path] }

      before do
        FileUtils.mkdir_p(File.dirname(ruby_path))
        File.write(ruby_path, 'class FooController; end')
        allow(Open3).to receive(:capture2e).and_return(["app/controllers/foo_controller.rb:1 - use scope access\n", double(success?: false)])
      end

      it 'returns fail with command output' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages.first).to match(/foo_controller|scope|best practice/i)
      end
    end
  end
end
