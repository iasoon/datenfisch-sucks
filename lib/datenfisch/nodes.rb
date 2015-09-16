require 'datenfisch/nodes/attribute'
require 'datenfisch/nodes/aggregate'
require 'datenfisch/nodes/predicates'
require 'datenfisch/utils'

module Datenfisch
  class NodeSet
    def initialize nodes = []
      @nodes = Set.new nodes
    end

    def arel
      # TODO: joins!
      set = AttributeSet.new @nodes
      table, attrs = set.first
      Utils.query
        .from(table.subquery(attrs))
        .project(@nodes.map(&:arel))
    end
  end

  # Groups attributes by table
  class AttributeSet
    include Enumerable

    def initialize nodes=[]
      @attrmap = Hash.new do |hash, table|
        hash[table] = Set.new
      end
      nodes.each { |node| add node }
    end

    def add node
      node.leaves.each do |attr|
        @attrmap[attr.table].add attr
      end
    end

    # yields [table, attrs] pairs
    def each &block
      @attrmap.each_pair &block
    end
  end
end
