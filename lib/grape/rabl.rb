require 'grape-rabl'

module Grape
  module Formatter
    module Rabl
      class << self
        def call(object, env)
          Grape::Rabl::Formatter.new(object, env).render
        end
      end
    end
  end
end
