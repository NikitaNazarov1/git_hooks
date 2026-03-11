# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitHooks::Checks::CommitMsg::JiraPrefix do
  let(:config) { described_class.definition.default_config }
  let(:repo_root) { Dir.mktmpdir('jira_prefix') }
  let(:repo) { instance_double(GitHooks::Repository, root: repo_root, current_branch: branch) }
  let(:msg_path) { File.join(repo_root, 'COMMIT_EDITMSG') }
  let(:context) { { repo: repo, applicable_files: [], argv: [msg_path], stdin: '' } }

  after { FileUtils.rm_rf(repo_root) }

  describe '#run' do
    context 'when argv has no message file' do
      let(:branch) { 'feature/APD-123' }
      let(:context) { { repo: repo, applicable_files: [], argv: [], stdin: '' } }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when branch has no ticket' do
      let(:branch) { 'main' }

      before { File.write(msg_path, 'Fix bug') }

      it 'returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
      end
    end

    context 'when branch has ticket and message already has prefix' do
      let(:branch) { 'feature/APD-456' }

      before { File.write(msg_path, '[APD-456] Fix bug') }

      it 'returns pass without modifying file' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
        expect(File.read(msg_path)).to include('[APD-456] Fix bug')
      end
    end

    context 'when branch has ticket and message lacks prefix' do
      let(:branch) { 'feature/TIX-99' }

      before { File.write(msg_path, "Add feature\n") }

      it 'prepends prefix and returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
        expect(File.read(msg_path)).to eq("[TIX-99] Add feature\n")
      end
    end

    context 'when branch has ticket with X(s) (placeholder id)' do
      let(:branch) { 'feature/PROJ-XX' }

      before { File.write(msg_path, "WIP\n") }

      it 'prepends prefix and returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
        expect(File.read(msg_path)).to eq("[PROJ-XX] WIP\n")
      end
    end

    context 'when branch has ticket with mixed-case project key (pattern is case-insensitive)' do
      let(:branch) { 'feature/abc-123' }

      before { File.write(msg_path, "Fix something\n") }

      it 'prepends prefix and returns pass' do
        check = described_class.new(config: config, context: context)
        expect(check.run).to be_pass
        expect(File.read(msg_path)).to eq("[abc-123] Fix something\n")
      end
    end
  end
end
