$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler'
Bundler.setup :default, :test

require 'grape-rabl'
require 'rspec'
require 'rack/test'
require 'ostruct'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

