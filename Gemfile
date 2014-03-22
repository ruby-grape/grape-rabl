source 'https://rubygems.org'

gemspec

group :development do
  gem "rubocop", "0.20.1"
end

group :test do
  gem "json", '~> 1.7.7'
  gem "rspec", "~> 2.12.0"
  gem "rack-test"
  gem "rake"
  gem "coveralls", require: false

  platforms :rbx do
    gem "iconv"
  end
end
