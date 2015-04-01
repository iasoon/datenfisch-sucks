module Datenfisch
  module QueryMethods
    def with_stats *stats
      include_stats stats
    end

    def only_with_stats *stats
      include_stats stats, inner_join: true
    end

    private
    def include_stats stats, **opts
      statmap = model.const_get "Stats"
      Datenfisch::query.model(self, **opts).select(
        *stats.map { |name| statmap[name] }
      )
    end
  end
end
