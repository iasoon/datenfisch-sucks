require 'datenfisch/tables/base'
require 'datenfisch/utils'
require 'datenfisch/names'
module Datenfisch
  module Tables
    class AggregateTable < Base
      def initialize table
        @table = table
      end

      def name
        Names.aggregator(@table)
      end

      def arel_for attributes
        #TODO this is not quite right. Table.arel should not be called
        # (You can't aggregate aggregate tables right now)
        Utils.query
          .from(@table.arel)
          .project(attributes.map {|a| a.aggregate.arel })
          .as(name)
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
