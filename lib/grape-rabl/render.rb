module Grape
  module Rabl
    module Render
      def render(options = {})
        env['api.tilt.rabl'] = options[:rabl]
        env['api.tilt.rabl_locals'] = options[:locals]
      end
    end
  end
end

Grape::Endpoint.send(:include, Grape::Rabl::Render)
