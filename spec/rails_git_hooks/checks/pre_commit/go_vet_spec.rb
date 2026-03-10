# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'tmpdir'

RSpec.describe GitHooks::Checks::PreCommit::GoVet do
  let(:config) { described_class.definition.default_config.merge('command' => %w[go vet]) }
  let(:repo_root) { Dir.mktmpdir('go_vet_spec') }
  let(:repo) { instance_double(GitHooks::Repository, root: repo_root) }
  let(:context) { { repo: repo, applicable_files: files, argv: [], stdin: '' } }

  after { FileUtils.rm_rf(repo_root) }

  describe '#run' do
    context 'when no Go files in applicable_files' do
      let(:files) { ['README.md'] }

      it 'returns pass without running command' do
        check = described_class.new(config: config, context: context)
        expect(Open3).not_to receive(:capture2e)
        expect(check.run).to be_pass
      end
    end

    context 'when command succeeds' do
      let(:go_path) { File.join(repo_root, 'main.go') }
      let(:files) { [go_path] }

      before do
        FileUtils.mkdir_p(File.dirname(go_path))
        File.write(go_path, "package main\nfunc main() {}")
        allow(Open3).to receive(:capture2e).and_return(['', double(success?: true)])
      end

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when command fails' do
      let(:go_path) { File.join(repo_root, 'main.go') }
      let(:files) { [go_path] }

      before do
        FileUtils.mkdir_p(File.dirname(go_path))
        File.write(go_path, "package main\nfunc main() {}")
        allow(Open3).to receive(:capture2e).and_return(
          ["main.go:2:12: unreachable code\n", double(success?: false)]
        )
      end

      it 'returns fail with command output' do
        check = described_class.new(config: config, context: context)
        result = check.run
        expect(result).to be_fail
        expect(result.messages).to include('main.go:2:12: unreachable code')
      end
    end
  end
end
