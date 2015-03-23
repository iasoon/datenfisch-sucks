module Datenfisch
  module StattedModel

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def instantiate record
        obj = super select_attributes(record)
        obj.add_stats select_stats(record)
        obj
      end

      private
      def select_attributes params
        params.select {|k,v| is_attribute? k}
      end

      def select_stats params
        params.reject {|k,v| is_attribute? k}
      end

      def is_attribute? name
        column_names.include? name.to_s
      end

    end

    def initialize *args, **nargs
      super(*args, **nargs)
      @stats = {}
    end

    def add_stats stats
      @stats = {} if not @stats
      @stats.merge! stats.stringify_keys
      stats.each do |name, value|
        add_stat_accessor name, value
      end
    end

    def add_stat_accessor name, value
      define_singleton_method name do
        value
      end
    end

    def attributes
      super.merge @stats
    end

  end

  module Statted
    def self.extended(klass)
      statted_klass = Class.new klass
      statted_klass.include StattedModel
      klass.const_set("Statted", statted_klass)
    end

    def instantiate_with_stats record
      self.const_get("Statted").instantiate record
    end
  end

end

