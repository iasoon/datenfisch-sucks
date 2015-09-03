require 'datenfisch/tables'
module Datenfisch
  # An aggregator aggregates aggregates.
  class Aggregator
    attr_reader :aggregates
    attr_reader :table

    def initialize table, aggregates = []
      @table = table
      @aggregates = Set.new aggregates
    end

    def add aggregate
      @aggregates.add aggregate
    end

    def arel
      Arel::SelectManager.new(ActiveRecord::Base)
        .from(@table.arel)
        .project(*@aggregates.map(&:arel))
        .as(Names.aggregator(@table))
    end
  end

  class AggregatorSet
    def initialize aggregates
      @aggregators = Hash.new do |hash, table|
        # Create a new aggregator for table when there is none
        hash[table] = Aggregator.new table
      end
      aggregates.each { |a| @aggregators.add a }
    end

    def arel
      #TODO
    end
  end
end
