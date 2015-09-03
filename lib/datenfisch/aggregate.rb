require 'datenfisch/tables'
module Datenfisch
  class Aggregate
    attr_reader :node

    def initialize node
      @node = node
    end

    def arel
      self.arel_node.as self.attr_name
    end

    def table
      Tables::AggregateTable.new @node.table
    end

    # Generate an unique name for this node
    def attr_name
      'n' + self.hash.abs.to_s(36)
    end

    def hash
      self.node.hash
    end

    def eql? other
      self.class == other.class && self.node == other.node
    end
    alias_method :==, :eql?
  end

  class Count < Aggregate
    def arel_node
      Arel::Nodes::Count.new [@node.arel]
    end
  end

end
