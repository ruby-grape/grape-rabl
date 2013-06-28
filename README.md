# Grape::Rabl

Use [Rabl](https://github.com/nesquena/rabl) templates in [Grape](https://github.com/intridea/grape)!

[![Build Status](https://secure.travis-ci.org/LTe/grape-rabl.png)](http://travis-ci.org/LTe/grape-rabl)
[![Dependency Status](https://gemnasium.com/LTe/grape-rabl.png)](https://gemnasium.com/LTe/grape-rabl)
[![Code Climate](https://codeclimate.com/github/LTe/grape-rabl.png)](https://codeclimate.com/github/LTe/grape-rabl)
[![Coverage Status](https://coveralls.io/repos/LTe/grape-rabl/badge.png?branch=master)](https://coveralls.io/r/LTe/grape-rabl?branch=master)
[![Gem Version](https://badge.fury.io/rb/grape-rabl.png)](http://badge.fury.io/rb/grape-rabl)

## Installation

Add the `grape` and `grape-rabl` gems to Gemfile.

```ruby
gem 'grape', "~> 0.2.3"
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

## Changelog

#### v0.2.0
* fix: render template according to request format [view commit](http://github.com/LTe/grape-rabl/commit/f9658cf7a3026122afbb77e0da613731a5828338)
* Stick to gem convencions [#11] [view commit](http://github.com/LTe/grape-rabl/commit/aabd0e2ad72f56a75427eebcc586deed57cf5f58)
* Allow to use partials in grape [#10] [view commit](http://github.com/LTe/grape-rabl/commit/72c96c5acc9d8000f56ee8400ae0229053fb3e7e)
* Format fix [view commit](http://github.com/LTe/grape-rabl/commit/13749cc18d332dcd0050bb32980cc233868a7992)
* update for grape 0.3 compatibility [view commit](http://github.com/LTe/grape-rabl/commit/78bfdceffbfe90b700868ff1e79ab87e8baded81)

#### v0.1.0

* Updated w/ released Grape 0.2.3. [view commit](http://github.com/LTe/grape-rabl/commit/9a055dfd8e13e0952a587de7a2e19c9f762e939c)
* Added link to Rabl. [view commit](http://github.com/LTe/grape-rabl/commit/2a7650cb5f9327761cac8b928453e451a973e131)
* Grape 0.2.x and put back dependency status. [view commit](http://github.com/LTe/grape-rabl/commit/9c1183f3758db8a79737ff35f0c328be646a3f65)
* Grape 0.2.3. [view commit](http://github.com/LTe/grape-rabl/commit/d06a6559a02095e1d84fbbd8df0c3eccdd31930b)
* Updated Grape dependency via .gemspec. [view commit](http://github.com/LTe/grape-rabl/commit/fd44b6a91fa327438eac968fea62ac00ec3ae01f)

#### v0.0.6
* Use Grape formatter syntax instead of monkey-patching. [view commit](http://github.com/LTe/grape-rabl/commit/bfba4c382933fd0f912d9114676b6d79d627c3be)
* Close block code in README [view commit](http://github.com/LTe/grape-rabl/commit/f397a0de4399d0797b5e327d56234464091d7e3d)
* Change home to user [view commit](http://github.com/LTe/grape-rabl/commit/45178ec13c613d872c65475b330d20a548459681)

#### v0.0.5
* Respect default_format for rabl response [view commit](http://github.com/LTe/grape-rabl/commit/ac54ebbb1d43d1fb76ee9516c5aa683c750c73b0)

#### v0.0.4
* Require grape/rabl [view commit](http://github.com/LTe/grape-rabl/commit/e99a185b20974f5e72ac3c19ec377a5853780a33)

#### v0.0.3
* Template without .rabl. Add specs. Update README [view commit](http://github.com/LTe/grape-rabl/commit/cecca03a680f8ae50b406e1b8c170eba27d1bc99)

#### v0.0.2
* Add travis [view commit](http://github.com/LTe/grape-rabl/commit/71c905bc91066c6fdb628afb555561e23219e213)
* Remove ruby debug [view commit](http://github.com/LTe/grape-rabl/commit/f80fad14a49b14ae7264b08eff12832c37cbd0b2)
* Works with rubinius [view commit](http://github.com/LTe/grape-rabl/commit/fceece344de095916ded7c477bb5891537bb8663)
* Add dependency status [view commit](http://github.com/LTe/grape-rabl/commit/66820fb52155c65d4cd9bd7b67f0f22c1105fa46)

#### v0.0.1
* First version

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
