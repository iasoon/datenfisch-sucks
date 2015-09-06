require 'datenfisch/tables/base'
require 'datenfisch/utils'
module Datenfisch
  module Tables
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
          .as(name)
      end
    end

    class Base
      def where *constraints
        # TODO make this method actually work
        WhereTable.new(self, constraints)
      end
    end
  end
end
