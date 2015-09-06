require 'datenfisch/nodes'
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

      def subquery nodes
        self.query(nodes).as(name)
      end

      def == other
        self.class == other.class &&
          self.arel_table == other.arel_table
      end
      alias_method :eql?, :==
    end
  end
end
