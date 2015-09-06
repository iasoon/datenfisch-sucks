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

      def query nodes
        @table.query(nodes).where(constraints)
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
