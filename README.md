# Grape::Rabl

Use Rabl templates in [Grape](https://github.com/intridea/grape)!

[![Build Status](https://secure.travis-ci.org/LTe/grape-rabl.png)](http://travis-ci.org/LTe/grape-rabl) [![Dependency Status](https://gemnasium.com/LTe/grape-rabl.png)](https://gemnasium.com/LTe/grape-rabl)


## Installation

Add the `grape` and `grape-rabl` gems to Gemfile. Currently requires HEAD of Grape.

```ruby
gem 'grape', :git => "https://github.com/intridea/grape.git"
gem 'grape-rabl'
```

And then execute:

    $ bundle

## Usage

### Require grape-rabl

```ruby
# config.ru
require 'grape/rabl'
```

### Setup view root directory
```ruby
# config.ru
require 'grape/rabl'

use Rack::Config do |env|
  env['api.tilt.root'] = '/path/to/view/root/directory'
end
```

### Tell your API to use Grape::Formatter::Rabl

```ruby
class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::Rabl
end
```

### Use rabl templates conditionally

Add the template name to the API options.

```ruby
get "/user/:id", :rabl => "user.rabl" do
  @user = User.find(params[:id])
end
```

You can use instance variables in the Rabl template.

```ruby
object @user => :user
attributes :name, :email

child @project => :project do
  attributes :name
end
```

## You can omit .rabl

The following are identical.

```ruby
get "/home", :rabl => "view"
get "/home", :rabl => "view.rabl"
```

### Example

```ruby
# config.ru
require 'grape/rabl'

use Rack::Config do |env|
  env['api.tilt.root'] = '/path/to/view/root/directory'
end

class UserAPI < Grape::API
  format :json
  formatter :json, Grape::Formatter::Rabl

  # use rabl with 'user.rabl' template
  get '/user/:id', :rabl => 'user' do
    @user = User.find(params[:id])
  end

  # do not use rabl, fallback to the defalt Grape JSON formatter
  get '/users' do
    User.all
  end
end
```

```ruby
# user.rabl
object @user => :user

attributes :name
```

## Usage with rails

Create grape application

```ruby
# app/api/user.rb
class MyAPI < Grape::API
  format :json
  formatter :json, Grape::Formatter::Rabl
  get '/user/:id', :rabl => "user" do
    @user = User.find(params[:id])
  end
end
```

```ruby
# app/views/api/user.rabl
object @user => :user
```

Edit your **config/application.rb** and add view path

```ruby
# application.rb
class Application < Rails::Application
  config.middleware.use(Rack::Config) do |env|
    env['api.tilt.root'] = Rails.root.join "app", "views", "api"
  end
end
```

Mount application to rails router

```ruby
# routes.rb
GrapeExampleRails::Application.routes.draw do
  mount MyAPI , :at => "/api"
end
```

## Rspec

See "Writing Tests" in https://github.com/intridea/grape.

Enjoy :)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
