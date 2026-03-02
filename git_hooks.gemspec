# frozen_string_literal: true

require_relative 'lib/git_hooks/version'

Gem::Specification.new do |spec|
  spec.name          = 'git_hooks'
  spec.version       = GitHooks::VERSION
  spec.authors       = ['Nikita Nazarov']
  spec.email         = ['']

  spec.summary       = 'Git hooks for Jira commit prefix and RuboCop on staged files'
  spec.description   = 'Installs commit-msg (Jira ticket prefix) and pre-commit (RuboCop) hooks into your git repository.'
  spec.homepage      = 'https://github.com/NikitaNazarov1/git_hooks'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage

  spec.files = Dir['lib/**/*', 'bin/*'] + %w[README.md LICENSE]
  spec.bindir        = 'bin'
  spec.executables   = ['git_hooks']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rubocop', '~> 1.0'
end
