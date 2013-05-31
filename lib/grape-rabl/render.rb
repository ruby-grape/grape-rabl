module GrapeRabl
  module Render
    def render(options = {})
      env['api.endpoint'].options[:route_options][:rabl] = options.delete(:rabl)
    end
  end
end

Grape::Endpoint.send(:include, GrapeRabl::Render)
