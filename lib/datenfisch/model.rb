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
    end

  end

  class StattedRecord < SimpleDelegator

    def initialize model, params
      @model = model
      @obj = @model.new select_attributes(params)
      super @obj

      @stats = select_stats params
      @stats.each do |name, value|
        add_stat name, value
      end
    end

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
      @model.column_names.include? name.to_s
    end
  end
end
