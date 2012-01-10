require 'tilt'
Rabl.register!

module Grape
  module Middleware
    class Formatter
      alias :old_after :after

      def after
        status, headers, bodies = *@app_response
        current_endpoint = env['api.endpoint']

        rabl(current_endpoint) do |template|
          engine = ::Tilt.new(File.join(env['api.tilt.root'], template))
          rendered = engine.render(current_endpoint, {})
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
        if template = endpoint.options[:route_options][:rabl]
          set_view_root unless env['api.tilt.root']
          template
        else
          false
        end
      end
  
      def set_view_root
        raise "Use Rack::Config to set 'api.tilt.root' in config.ru"
      end
    end
  end
end
