# Grape::Rabl

Use rabl templates in grape!

[![Build Status](https://secure.travis-ci.org/LTe/grape-rabl.png)](http://travis-ci.org/LTe/grape-rabl) [![Dependency Status](https://gemnasium.com/LTe/grape-rabl.png)](https://gemnasium.com/LTe/grape-rabl)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-rabl'
gem 'grape', :git => "git://github.com/intridea/grape.git", :branch => "frontier"
```

And then execute:

    $ bundle

## Usage

### Require grape-rabl
```ruby
# config.ru
require 'grape-rabl'
```

### Setup view root directory
```ruby
# config.ru
require 'grape-rabl'

use Rack::Config do |env|
  env['api.tilt.root'] = '/path/to/view/root/directory'
end
```

### Create grape application

To *get post put delete options* add **:rabl** options with template name.

```ruby
get "/path", :rabl => "template_name" do
  # stuff
  @var = "hello"
end

post "/path", :rabl => "template_name_diff" do
  # stuff
  @user = User.find_user("email@example.com")
end
```

**You can use instance variables in templates!**

## Template name

You can use "**view.rabl**" or just "**view**"

```ruby
get "/home", :rabl => "view"
get "/home", :rabl => "view.rabl"
```

### Example

```ruby
# config.ru
require 'grape-rabl'

use Rack::Config do |env|
  env['api.tilt.root'] = '/path/to/view/root/directory'
end

class UserAPI < Grape::API
  # use rabl with 'hello.rabl' template
  get '/user', :rabl => 'hello' do
    @user = User.first
  end

  # do not use rabl, normal usage
  get '/user2' do
    { :some => :hash }
  end
end
```

```ruby
# hello.rabl
object @user => :user

attributes :name
```


Enjoy :)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
