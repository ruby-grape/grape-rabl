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
              engine = ::Tilt.new(view_path(template), tilt_options)
              output = engine.render endpoint, {}
              if !layout_template.nil?
                layout_template.render(endpoint) { output }
              else
                output
              end
            end
          else
            Grape::Formatter::Json.call object, env
          end

        end

        private

          def view_path(template)
            if template.split(".")[-1] == "rabl"
              File.join(env['api.tilt.root'], env['api.version'].to_s, template)
            else
              File.join(env['api.tilt.root'], env['api.version'].to_s, (template + ".rabl"))
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

          def tilt_options
            {format: env['api.format'], view_path: env['api.tilt.root']}
          end

          def layout_template
            layout_path = view_path(env['api.tilt.layout'] || 'layouts/application')
            if File.exists?(layout_path)
              ::Tilt.new(layout_path, tilt_options)
            else
              nil
            end
          end
      end
    end
  end
end
