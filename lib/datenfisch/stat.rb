require 'datenfisch/nodes'
module Datenfisch

  module Nodes

    class PrimaryStat < Node

      attr_reader :name, :provider

      def initialize name, primary_node, provider
        @name = name
        @primary_node = primary_node.as(@name.to_s)
        @provider = provider
      end

      def node
        secondary_node.node
      end

      def named_node
        secondary_node.as(@name).named_node
      end

      def primary_node
        @primary_node.named_node
      end

      def dependencies
        Set.new.add self
      end

      private
      # Todo: Do not use 0 as hardcoded default.
      def secondary_node
        Column.new(@provider.table, @name).coalesce(0)
      end
    end
  end
end
