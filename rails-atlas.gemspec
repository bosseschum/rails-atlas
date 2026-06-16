# frozen_string_literal: true

require_relative 'lib/atlas/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails-atlas'
  spec.version       = Atlas::VERSION
  spec.authors       = ['Bosse Schumacher']
  spec.email         = ['mail@bschum.de']

  spec.summary       = 'Architecture visualization for Rails applications'
  spec.description   = 'Analyze Rails models, associations, dependencies, and architecture through CLI and web UI.'
  spec.homepage      = 'https://github.com/bosseschum/rails-atlas'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.2'

  spec.files = Dir[
    'lib/**/*',
    'bin/*',
    'README.md',
    'LICENSE'
  ]

  spec.bindir        = 'bin'
  spec.executables   = ['atlas']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'json'
  spec.add_dependency 'prism'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'rubocop'
end
