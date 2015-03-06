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

    # Convenience method. Provide stat names instead of stat objects.
    def with_stats *stats
      Datenfisch::query.model(self).select(*stats.map { |name| send(name) })
    end

    def self.extended model
      model.const_set "DatenfischStats", {}
      statted_model model
    end

    def self.statted_model model
      klass = Class.new SimpleDelegator do
        include Stats
        const_set "Model", model

        def initialize params
          @obj = self.class.const_get("Model").new select_attributes(params)
          super @obj

          @stats = select_stats params
          @stats.each do |name, value|
            add_stat name, value
          end
        end

      end
      model.const_set "Statted", klass
    end

    module Stats

      def add_stat name, value
        define_singleton_method name do
          value
        end
      end

      private

      def select_attributes params
        params.select {|k,v| is_attribute? k}
      end

      def select_stats params
        params.reject {|k,v| is_attribute? k}
      end

      def is_attribute? name
        self.class.const_get("Model").column_names.include? name.to_s
      end
    end

  end

end
