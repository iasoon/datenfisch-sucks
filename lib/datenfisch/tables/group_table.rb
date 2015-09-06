require 'datenfisch/tables/base'
require 'datenfisch/utils'
module Datenfisch
  module Tables
    class GroupTable < Base
      def initialize table, group_node
        @table = table
        @group_node = group_node
      end

      def query nodes
        @table.query(nodes).group(@group_node.arel)
      end
    end

    class Base
      def group node
        GroupTable.new(self, node)
      end
    end
  end
end
