# frozen_string_literal: true

require File.expand_path('lib/grape-rabl/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ['Piotr Niełacny']
  gem.email         = ['piotr.nielacny@gmail.com']
  gem.description   = 'Use rabl in grape'
  gem.summary       = 'Use rabl in grape'
  gem.homepage      = 'https://github.com/ruby-grape/grape-rabl'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.name          = 'grape-rabl'
  gem.require_paths = ['lib']
  gem.version       = Grape::Rabl::VERSION
  gem.required_ruby_version = '>= 2.7.0'

  gem.add_dependency 'grape'
  gem.add_dependency 'i18n'
  gem.add_dependency 'rabl'
  gem.add_dependency 'tilt'
  gem.metadata['rubygems_mfa_required'] = 'true'
end
