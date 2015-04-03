module Datenfisch
  module Nodes

    class Alias < Node
      def initialize arg, name
        @arg = arg
        @name = name
      end

      def node
        @arg.node
      end

      def named_node
        Arel::Nodes::As.new @arg.node, @name
      end

      def dependencies
        @arg.dependencies
      end
    end

    class UnaryFunction < Node
      def initialize arg
        @arg = arg
      end

      def dependencies
        @arg.dependencies
      end
    end

    class BinaryFunction < Node
      def initialize left, right
        @left = left
        @right = right
      end

      def dependencies
        @left.dependencies + @right.dependencies
      end
    end

    class Coalesce < Node
      def initialize *args
        @args = args
      end

      def node
        Arel::Nodes::NamedFunction.new 'COALESCE', @args.map(&:node)
      end

      def dependencies
        @args.map(&:dependencies).reduce(&:+)
      end
    end

    class TypeCast < Node
      def initialize arg, type
        @arg = arg
        @type = type
      end

      def node
        Arel::Nodes::NamedFunction.new 'CAST',
          [Arel::Nodes::As.new(@arg.node, Arel::SqlLiteral.new(@type))]
      end
    end

    class Logarithm < UnaryFunction
      def node
        Arel::Nodes::NamedFunction.new 'LN', [@arg.node]
      end
    end

    class Sum < UnaryFunction
      def node
        Arel::Nodes::Sum.new [@arg.node]
      end
    end

    class Count < UnaryFunction
      def node
        Arel::Nodes::Count.new [@arg.node]
      end
    end

    class Addition < BinaryFunction
      def node
        Arel::Nodes::Addition.new @left.node, @right.node
      end
    end

    class Subtraction < BinaryFunction
      def node
        Arel::Nodes::Subtraction.new @left.node, @right.node
      end
    end

    class Multiplication < BinaryFunction
      def node
        Arel::Nodes::Multiplication.new @left.node, @right.node
      end
    end

    class Division < BinaryFunction
      def node
        Arel::Nodes::Division.new @left.node, @right.node
      end
    end
  end
end
