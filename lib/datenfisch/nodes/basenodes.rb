module Datenfisch
  module Nodes
    class Node
      def get *args, **named_args
        query = Datenfisch.query.select(self).where(*args, **named_args)
        res = ActiveRecord::Base.connection.execute(query.to_sql)
        res.first.first
      end
    end

    class BaseNode < Node
      def dependencies
        Set.new
      end
    end

    class Column < BaseNode
      def initialize table, name
        @table = table
        @name = name
      end

      def node
        @table[@name]
      end
    end

    class Literal < BaseNode
      def initialize value
        @value = value
      end

      def node
        Arel::Nodes::SqlLiteral.new @value
      end
    end

    class Volatile < BaseNode
      def initialize procedure
        @proc = procedure
      end

      def node
        Arel::Nodes::SqlLiteral.new @proc.yield.to_s
      end
    end
  end
end
