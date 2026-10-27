# frozen_string_literal: true

module Grape
  module Rabl
    class Configuration
      attr_accessor :cache_template_loading, :tilt_root

      def initialize
        @cache_template_loading = false
        @tilt_root = nil
      end
    end
  end
end
