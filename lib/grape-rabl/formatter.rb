require 'json'

module Grape
  module Rabl
    class Formatter
      class << self
        def tilt_cache
          @tilt_cache ||= ::Tilt::Cache.new
        end
      end

      attr_reader :env, :endpoint, :object

      def initialize(object, env)
        @env      = env
        @endpoint = env['api.endpoint']
        @object   = object
      end

      def render
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
          fallback_formatter = Grape::Formatter::Base.formatter_for(env['api.format']) || Grape::Formatter::Json
          fallback_formatter.call object, env
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
        !!rabl_template
      end

      def rabl
        raise 'missing rabl template' unless rabl_template
        set_view_root unless env['api.tilt.root']
        yield rabl_template
      end

      def locals
        env['api.tilt.rabl_locals'] || endpoint.options[:route_options][:rabl_locals] || {}
      end

      def rabl_template
        env['api.tilt.rabl'] || endpoint.options[:route_options][:rabl]
      end

      def set_view_root
        raise "Use Rack::Config to set 'api.tilt.root' in config.ru"
      end

      def tilt_template(template)
        if Grape::Rabl.configuration.cache_template_loading
          Grape::Rabl::Formatter.tilt_cache.fetch(tilt_cache_key(template)) { ::Tilt.new(view_path(template), tilt_options) }
        else
          ::Tilt.new(view_path(template), tilt_options)
        end
      end

      def tilt_options
        { format: env['api.format'], view_path: env['api.tilt.root'] }
      end

      def layout_template
        layout_path = view_path(env['api.tilt.layout'] || 'layouts/application')
        if Grape::Rabl.configuration.cache_template_loading
          Grape::Rabl::Formatter.tilt_cache.fetch(tilt_cache_key(layout_path)) { ::Tilt.new(layout_path, tilt_options) if File.exist?(layout_path) }
        else
          ::Tilt.new(layout_path, tilt_options) if File.exist?(layout_path)
        end
      end

      def tilt_cache_key(path)
        Digest::MD5.hexdigest("#{path}#{tilt_options}")
      end
    end
  end
end
