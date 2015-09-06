require 'datenfisch/tables/base'
require 'datenfisch/utils'
module Datenfisch
  module Tables
    class GroupTable < Base
      def initialize table, group_node
        @table = table
        @group_node = group_node
      end

      def arel
        # TODO: do not call table.arel
        # TODO: fix this method
        Utils.query
          .from(@table.arel)
          .project(Arel.star)
          .group(@group_node.arel)
          .as(name)
      end
    end

    class Base
      def group node
        GroupTable.new(self, node)
      end
    end
  end
end
