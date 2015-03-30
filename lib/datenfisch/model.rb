require 'delegate'
module Datenfisch

  module Model
    def stat name, stat
      # Alias stat with given name
      stat = stat.as name

      # Add stat to hash
      self.const_get("DatenfischStats")[name.to_sym] = stat

      # Define stat getter
      define_method name do |*args, **named_args|
        query = Datenfisch::query.select(stat)
          .where(self.class.name.downcase.concat('_id') => id)
          .where(*args, **named_args)

        # Extract result
        query.run.first[stat.name.to_s]
      end

      # Define getter for stat object
      define_singleton_method name do
        stat
      end

    end


    def self.extended model
      model.const_set "DatenfischStats", {}
    end

    # Convenience method. Provide stat names instead of stat objects.
    def with_stats *stats
      include_stats stats
    end

    def only_with_stats *stats
      include_stats stats, inner_join: true
    end

    private
    def include_stats stats, **opts
      Datenfisch::query.model(self, **opts).select(
        *stats.map { |name| send(name) }
      )
    end

  end
end
