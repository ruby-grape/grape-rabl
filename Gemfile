# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'grape', "~> #{ENV['GRAPE_VERSION']}.0" if ENV['GRAPE_VERSION']
gem 'rack', '~> 2.2' if ENV['GRAPE_VERSION'] == '1'

group :development do
  gem 'rubocop', '~> 1.92.0', require: false
  gem 'ruby-grape-danger', '~> 0.3.0', require: false
end

group :test do
  gem 'builder'
  gem 'json'
  gem 'rabl'
  gem 'rack-test'
  gem 'rake'
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
end
