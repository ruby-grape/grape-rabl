require 'tilt'

module Grape
  module Middleware
    class Formatter
      alias :old_after :after

      def after
        status, headers, bodies = *@app_response

        rabl(bodies.first) do |template|
          engine = ::Tilt.new(File.join(env['api.tilt.root'], template))
          rendered = engine.render(bodies.first, {})
          Rack::Response.new(rendered, status, headers).to_a
        end
      end

      def rabl(endpoint)
        if template = rablable?(endpoint)
          yield template
        else
          old_after
        end
      end

      def rablable?(endpoint)
        set_view_root unless env['api.tilt.root']
        endpoint.is_a?(Grape::Endpoint) && endpoint.options[:route_options][:rabl]
      end
  
      def set_view_root
        raise "Use Rack::Config to set 'api.tilt.root' in config.ru"
      end
    end
  end
end
