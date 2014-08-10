module Grape
  module Rabl
    class Configuration
      attr_accessor :cache_template_loading

      def initialize
        @cache_template_loading = false
      end
    end
  end
end
