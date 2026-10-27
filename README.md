# Grape::Rabl

Use [Rabl](https://github.com/nesquena/rabl) templates in [Grape](https://github.com/ruby-grape/grape)!

[![Gem Version](https://img.shields.io/gem/v/grape-rabl.svg)](https://rubygems.org/gems/grape-rabl)
[![Build Status](https://github.com/ruby-grape/grape-rabl/actions/workflows/test.yml/badge.svg?branch=master&event=push)](https://github.com/ruby-grape/grape-rabl/actions/workflows/test.yml?query=branch%3Amaster)
[![Coverage Status](https://coveralls.io/repos/github/ruby-grape/grape-rabl/badge.svg?branch=master)](https://coveralls.io/github/ruby-grape/grape-rabl?branch=master)

# Table of Contents

- [Installation](#installation)
- [Upgrading](#upgrading)
- [Usage](#usage)
  - [Setup view root directory](#setup-view-root-directory)
  - [Configure request-aware view roots](#configure-request-aware-view-roots)
  - [Tell your API to use Grape::Formatter::Rabl](#tell-your-api-to-use-grapeformatterrabl)
  - [Use rabl templates conditionally](#use-rabl-templates-conditionally)
  - [Use rabl layout](#use-rabl-layout)
  - [Enable template caching](#enable-template-caching)
- [You can omit .rabl](#you-can-omit-rabl)
  - [Example](#example)
- [Usage with rails](#usage-with-rails)
- [Swagger documentation](#swagger-documentation)
- [Specs](#specs)
- [Contributing](#contributing)

## Installation

Requires Ruby 2.7 or newer. CI covers Grape 1.x, 2.x, 3.x, and 4.x; Grape 3.x and 4.x are tested on Ruby 3.3 and newer. Grape 1.x requires Rack 2.x.

Add the `grape` and `grape-rabl` gems to Gemfile.

```ruby
gem 'grape'
gem 'grape-rabl'
```

And then execute:

    $ bundle

## Upgrading

See [UPGRADING](UPGRADING.md).

## Usage

### Setup view root directory

```ruby
# config.ru
use Rack::Config do |env|
  env['api.tilt.root'] = '/path/to/view/root/directory'
end
```

### Configure request-aware view roots

Instead of setting a root with middleware, configure a static directory or a zero-argument Proc/lambda:

```ruby
Grape::Rabl.configure do |config|
  config.tilt_root = -> { File.join('/path/to/views', env['api.version'].to_s) }
end
```

The Proc runs in the current Grape endpoint's context, so it can access `env`, `params`, and API helpers. The example uses `/path/to/views/v1` for version `v1` and `/path/to/views` for an unversioned request. Version directories are opt-in: a static `config.tilt_root` or existing `env['api.tilt.root']` is used unchanged.

An explicit `env['api.tilt.root']` takes precedence over the configured root, and the Proc is not called in that case. Resolution happens only when rendering a Rabl template; the resolved root is stored in the request environment, not back into configuration. Templates, partials, and layouts use that root, and cached templates remain separated by resolved directory and format. Resolver exceptions propagate; returning `nil` or `false` raises the missing-root configuration error.

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

### Use rabl layout

Gape-rabl first looks for a layout file in `#{env['api.tilt.root']}/layouts/application.rabl`.

You can override the default layout conventions:

```ruby
# config.ru
use Rack::Config do |env|
  env['api.tilt.root'] = '/path/to/view/root/directory'
  env['api.tilt.layout'] = 'layouts/another'
end
```

### Enable template caching

Grape-rabl allows for template caching after templates are loaded initially.

Template creation and cache lookups are synchronized across requests, including cached missing layouts. Caching does not depend on the deprecated `Tilt::Cache` class. Disable caching during development if templates need to reload after changes.

You can enable template caching:

```ruby
# config.ru
Grape::Rabl.configure do |config|
  config.cache_template_loading = true # default: false
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
use Rack::Config do |env|
  env['api.tilt.root'] = '/path/to/view/root/directory'
end

class UserAPI < Grape::API
  format :json
  formatter :json, Grape::Formatter::Rabl

  get '/user/:id' do
    @user = User.find(params[:id])

    # use rabl with 'user.rabl' or 'admin.rabl' template
    if @user.admin?
      # pass locals with the #render method
      render rabl: 'admin', locals: { details: 'this user is an admin' }
    else
      render rabl: 'user'
    end
  end

  get '/admin/:id', :rabl => 'admin' do
    @user = User.find(params[:id])

    # use rabl with 'super_admin.rabl'
    render rabl: 'super_admin' if @user.super_admin?
    # when render method has not been used use template from endpoint definition
  end

  # use rabl with 'user_history.rabl' template
  get '/user/:id/history', :rabl => 'user_history' do
    @history = User.find(params[:id]).history
  end

  # do not use rabl, fallback to the default Grape response formatter
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

## Swagger documentation

Use [grape-swagger](https://github.com/ruby-grape/grape-swagger) to generate Swagger/OpenAPI 2.0 documentation. Rabl still renders the responses: Swagger does not infer a response schema by executing a template or reading its Ruby code.

One option is to define documentation-only entities with the optional [grape-swagger-entity](https://github.com/ruby-grape/grape-swagger-entity) parser. Add these gems to your application's Gemfile, choosing versions compatible with your Grape version:

```ruby
gem 'grape-rabl'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-entity'
```

Load the parser before generating documentation. For example, with an application-provided `User` model:

```ruby
# config.ru
require 'grape/rabl'
require 'grape-swagger'
require 'grape-swagger/entity'

class UserFields < Grape::Entity
  expose :id, documentation: { type: Integer }
  expose :name, documentation: { type: String }
end

class UserResponse < Grape::Entity
  expose :user, using: UserFields
end

class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::Rabl

  desc 'Return a user', success: UserResponse
  get '/users/:id', rabl: 'user' do
    @user = User.find(params[:id])
  end

  add_swagger_documentation
end

use Rack::Config do |env|
  env['api.tilt.root'] = File.expand_path('views', __dir__)
end
run API
```

```ruby
# views/user.rabl
object @user => :user
attributes :id, :name
```

`GET /users/1` returns a Rabl-rendered response such as `{ "user": { "id": 1, "name": "Jane" } }`. `GET /swagger_doc` returns the documentation, with the endpoint's success response referencing `UserResponse` and its nested `UserFields` definition.

The entities describe the output only; do not call `present` or replace the Rabl formatter with an Entity formatter. `success: UserResponse` selects the documented schema, not the response serializer. Documentation endpoints have no Rabl template and use the normal JSON fallback.

Keep the schema aligned with the actual template, including root envelopes, collections, layouts, partials, and conditional fields. These are not inferred from Rabl automatically. For a schema system other than Entity, use grape-swagger's [custom model parser interface](https://github.com/ruby-grape/grape-swagger#custom-model-parsers). None of these documentation dependencies is required for normal Rabl rendering.

## Specs

Spec runs generate `coverage/lcov/grape-rabl.lcov` with SimpleCov. CI merges coverage from every stable Ruby/Grape matrix job in Coveralls using the built-in GitHub token; ruby-head remains experimental and does not publish coverage.

See ["Writing Tests"](https://github.com/ruby-grape/grape#writing-tests) in [grape](https://github.com/ruby-grape/grape) README.

Enjoy :)

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).
