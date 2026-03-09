# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitHooks::DependencyChecker do
  around do |example|
    Dir.mktmpdir('rails_git_hooks_dependency_spec') do |tmpdir|
      @repo = Struct.new(:root).new(tmpdir)
      example.run
    end
  end

  let(:checker) { described_class.new(repo: @repo) }

  it 'returns pass when dependencies are available or empty' do
    result = checker.check('dependencies' => {})
    expect(result).to be_pass
  end

  it 'returns missing dependency failure for absent files' do
    result = checker.check(
      'dependencies' => { 'files' => ['tmp/missing.txt'] },
      'install_hint' => 'Create the file first'
    )

    expect(result).to be_fail
    expect(result.reason).to eq(:missing_dependency)
    expect(result.messages).to include('missing file: tmp/missing.txt')
    expect(result.messages).to include('Create the file first')
  end
end
