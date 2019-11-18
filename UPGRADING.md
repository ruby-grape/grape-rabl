# Upgrading Grape::Rabl

## Upgrading to >= 0.5

### Fallback rendering when no RABL template is defined

Prior to v0.5.0, Grape::Rabl would always render content as JSON when no Rabl template was specified for a request. Beginning in v0.5.0 Grape::Rabl will now fallback to using the default response format [as determined by Grape](https://github.com/ruby-grape/grape#api-formats)

```ruby
class SampleApi < Grape::API
  format :xml
  formatter :xml, Grape::Formatter::Rabl

  get 'list' do
    render %w[thing]
  end
end
```

#### Former behavior

```ruby
response.body # => ["thing"]
```

#### Current behavior

```ruby
response.body # => <?xml version="1.0" encoding="UTF-8"?>\n<strings type="array">\n  <string>thing</string>\n</strings>
```

See [#34](https://github.com/ruby-grape/grape-rabl/pull/34) for more information.
