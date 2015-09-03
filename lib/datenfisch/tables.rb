require 'datenfisch/nodes'

require 'datenfisch/names'
module Datenfisch
  module Tables
    class Base
      def [] name
        Nodes::Attribute.new self, name
      end

      def hash
        arel_table.hash
      end

      def arel_for attributes
        arel
      end

      def arel_table
        Arel::Table.new(Names.table(self))
      end

      def aggregate_table
        AggregateTable.new self
      end

      def == other
        self.class == other.class &&
          self.arel_table == other.arel_table
      end
      alias_method :eql?, :==
    end

    class Table < Base
      def initialize model
        @table = model.arel_table
      end

      def arel_table
        @table
      end

      def arel
        arel_table
      end
    end

    class AggregateTable < Base
      def initialize table
        @table = table
      end

      def table_name
        Names.aggregator(@table)
      end

      def arel_table
        Arel::Table.new(table_name)
      end

      def arel_for attributes
        #TODO this is not quite right. Table.arel should not be called
        # (You can't aggregate aggregate tables right now)
        Arel::SelectManager.new(ActiveRecord::Base)
          .from(@table.arel)
          .project(attributes.map {|a| a.aggregate.arel })
          .as(table_name)
      end
    end
  end
end
