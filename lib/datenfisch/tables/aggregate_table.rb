require 'datenfisch/tables/base'
require 'datenfisch/utils'
require 'datenfisch/names'
module Datenfisch
  module Tables
    # Wrapper for selecting aggregates
    class AggregateTable < Base
      def initialize table
        @table = table
      end

      def name
        Names.aggregator(@table)
      end

      def query nodes
        @table.query(nodes.map {|n| n.aggregate.arel})
      end

      def hash
        @table.hash
      end
    end

    class Base
      def aggregate_table
        AggregateTable.new self
      end
    end
  end
end
