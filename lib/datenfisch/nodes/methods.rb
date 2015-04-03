require 'datenfisch/nodes/combinators'
require 'datenfisch/nodes/convertions'

module Datenfisch
  module Nodes
    module Methods
      using Convertions

      def as name
        Alias.new self, name
      end

      def + other
        Addition.new self, other.to_node
      end

      def - other
        Subtraction.new self, other.to_node
      end

      def * other
        Multiplication.new self, other.to_node
      end

      def / other
        Division.new self, other.to_node
      end

      def sum
        Sum.new self
      end

      def count
        Count.new self
      end

      def round
        TypeCast.new self, 'SIGNED'
      end

      def coalesce *args
        Coalesce.new(self, *args.map { |a| a.to_node })
      end
    end

    Node.include Methods
  end
end
