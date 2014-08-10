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
              engine = tilt_template(template)
              output = engine.render endpoint, locals
              if layout_template
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
          if template.split('.')[-1] == 'rabl'
            File.join(env['api.tilt.root'], template)
          else
            File.join(env['api.tilt.root'], (template + '.rabl'))
          end
        end

        def rablable?
          !!endpoint.options[:route_options][:rabl]
        end

        def rabl
          template = endpoint.options[:route_options][:rabl]
          fail 'missing rabl template' unless template
          set_view_root unless env['api.tilt.root']
          yield template
        end

        def locals
          endpoint.options[:route_options][:rabl_locals] || {}
        end

        def set_view_root
          fail "Use Rack::Config to set 'api.tilt.root' in config.ru"
        end

        def tilt_template(template)
          if Grape::Rabl.configuration.cache_template_loading
            tilt_cache.fetch(template) { ::Tilt.new(view_path(template), tilt_options) }
          else
            ::Tilt.new(view_path(template), tilt_options)
          end
        end

        def tilt_cache
          @tilt_cache ||= ::Tilt::Cache.new
        end

        def tilt_options
          { format: env['api.format'], view_path: env['api.tilt.root'] }
        end

        def layout_template
          layout_path = view_path(env['api.tilt.layout'] || 'layouts/application')
          if Grape::Rabl.configuration.cache_template_loading
            tilt_cache.fetch(layout_path) { ::Tilt.new(layout_path, tilt_options) if File.exist?(layout_path) }
          else
            ::Tilt.new(layout_path, tilt_options) if File.exist?(layout_path)
          end
        end
      end
    end
  end
end
