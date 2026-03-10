# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'tmpdir'

RSpec.describe GitHooks::Checks::PreCommit::Jslint do
  let(:config) { described_class.definition.default_config.merge('command' => %w[jslint]) }
  let(:repo_root) { Dir.mktmpdir('jslint_spec') }
  let(:repo) { instance_double(GitHooks::Repository, root: repo_root) }
  let(:context) { { repo: repo, applicable_files: files, argv: [], stdin: '' } }

  after { FileUtils.rm_rf(repo_root) }

  describe '#run' do
    context 'when no JavaScript files in applicable_files' do
      let(:files) { ['config/settings.yml'] }

      it 'returns pass without running command' do
        check = described_class.new(config: config, context: context)
        expect(Open3).not_to receive(:capture2e)
        expect(check.run).to be_pass
      end
    end

    context 'when command succeeds' do
      let(:js_path) { File.join(repo_root, 'app/javascript/foo.js') }
      let(:files) { [js_path] }

      before do
        FileUtils.mkdir_p(File.dirname(js_path))
        File.write(js_path, 'console.log("ok");')
        allow(Open3).to receive(:capture2e).and_return(['', double(success?: true)])
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when command fails' do
      let(:js_path) { File.join(repo_root, 'app/javascript/foo.js') }
      let(:files) { [js_path] }

      before do
        FileUtils.mkdir_p(File.dirname(js_path))
        File.write(js_path, 'console.log("ok");')
        allow(Open3).to receive(:capture2e).and_return(["foo.js:1:1: Unexpected 'console'.\n", double(success?: false)])
      end

      it 'returns fail with command output' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages).to include("foo.js:1:1: Unexpected 'console'.")
      end
    end
  end
end
