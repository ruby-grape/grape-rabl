module GrapeRabl
  module Render
    def render(options = {})
      env['api.endpoint'].options[:route_options][:rabl] = options.delete(:rabl) if options.include?(:rabl)
      env['api.endpoint'].options[:route_options][:rabl_locals] = options.delete(:locals)
    end
  end
end

Grape::Endpoint.send(:include, GrapeRabl::Render)
