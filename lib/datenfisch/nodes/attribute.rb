module Datenfisch
  module Nodes
    class Attribute < Base
      attr_reader :table, :name

      def initialize table, name
        @table = table
        @name = name
      end

      def arel
        arel_table[@name]
      end

      def arel_table
        @table.arel_table
      end

      def leaves
        [self]
      end

      def where *conditions
        Attribute.new(@table.where(*conditions), @name)
      end

      # TODO: have another look at this, it looks quirky.
      def group node
        Attribute.new(@table.group(node), @name)
      end

      def hash
        @table.hash ^ @name.hash
      end

      def eql? other
        self.class == other.class &&
          self.table == other.table &&
          self.name == other.name
      end
      alias_method :==, :eql?
    end
  end
end
