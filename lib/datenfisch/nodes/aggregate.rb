module Datenfisch
  module Nodes
    class Aggregate < Base
      attr_reader :aggregate

      def initialize aggregate
        @aggregate = aggregate
      end

      def leaves
        [self]
      end

      def arel
        arel_table[name]
      end

      def name
        @aggregate.attr_name
      end

      def arel_table
        @aggregate.table.arel_table
      end

      def table
        @aggregate.table
      end

      def where *conditions
        @aggregate.where(*conditions)
      end

      def group node
        @aggregate.group node
      end

      def hash
        @aggregate.hash
      end

      def eql? other
        self.aggregate == other.aggregate
      end
      alias_method :==, :eql?
    end
  end
end
