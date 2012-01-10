module Grape
  class Endpoint
    protected
    alias :old_run :run

    def run(env)
      @body = self if options[:route_options][:rabl]
      old_run(env)
    end
  end
end
