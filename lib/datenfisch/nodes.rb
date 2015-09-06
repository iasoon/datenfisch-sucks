require 'datenfisch/aggregator'
require 'datenfisch/utils'

module Datenfisch
  module Nodes
    class Attribute
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

    class Aggregate
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
