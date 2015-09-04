require 'datenfisch/nodes'
require 'datenfisch/names'
require 'datenfisch/utils'
module Datenfisch
  module Tables
    class Base
      def [] name
        Nodes::Attribute.new self, name
      end

      def name
        Names.table(self)
      end

      def arel_for attributes
        arel
      end

      def arel_table
        Arel::Table.new(name)
      end

      def aggregate_table
        AggregateTable.new self
      end

      def where *constraints
        # TODO make this method more intelligent
        WhereTable.new(self, constraints)
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

      def hash
        @table.hash
      end
    end

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

    class WhereTable < Base
      def initialize table, constraints
        @table = table
        @constraints = constraints
      end

      def hash
        @table.hash ^ @constraints.hash
      end

      def arel
        # TODO: support aggregate tables
        # TODO: Do not use subqueries when unneeded
        Utils.query
          .from(@table.arel)
          .project(Arel.star)
          .where(@constraints)
          .as(Names.table(self))
      end
    end
  end
end
