require 'json'

module Grape
  module Formatter
    module Rabl
      class << self

        attr_reader :env
        attr_reader :endpoint

        def call(object, env)

          @env = env
          @endpoint = env['api.endpoint']

          if rablable?
            rabl do |template|
              engine = ::Tilt.new(view_path(template), {format: env['api.format'], view_path: env['api.tilt.root']})
              engine.render endpoint, {}
            end
          else
            Grape::Formatter::Json.call object, env
          end

        end

        private

          def view_path(template)
            if template.split(".")[-1] == "rabl"
              File.join(env['api.tilt.root'], template)
            else
              File.join(env['api.tilt.root'], (template + ".rabl"))
            end
          end

          def rablable?
            !! endpoint.options[:route_options][:rabl]
          end

          def rabl
            template = endpoint.options[:route_options][:rabl]
            raise "missing rabl template" unless template
            set_view_root unless env['api.tilt.root']
            yield template
          end

          def set_view_root
            raise "Use Rack::Config to set 'api.tilt.root' in config.ru"
          end

      end
    end
  end
end
