module Datenfisch

  module Stats

    class Stat

      def as name
        NamedStat.new name, self
      end

      # basic arithmetic
      def + other
        Addition.new self, other
      end

      def - other
        Subtraction.new self, other
      end

      def * other
        Multiplication.new self, other
      end

      def / other
        Division.new self, other
      end

      private
      def to_stat arg
        arg = Constant.new arg if not arg.is_a? Stat
        arg
      end
    end

    class NamedStat < Stat
      attr_reader :name

      def initialize name, stat
        @name = name
        @stat = stat
      end

      def named_node
        Arel::Nodes::As.new(node, @name)
      end

      def node
        @stat.node
      end

      def dependencies
        @stat.dependencies
      end
    end

    class PrimaryStat < Stat

      attr_reader :name, :provider, :primary_node

      def initialize name, primary_node, provider
        @name = name
        @primary_node = primary_node.as(@name.to_s)
        @provider = provider
      end

      # Todo: Do not use 0 as hardcoded default.
      def node
        coalesce @provider.table[@name], 0
      end

      def named_node
        Arel::Nodes::As.new(node, @name)
      end

      def dependencies
        Set.new.add self
      end

      def coalesce *nodes
        Arel::Nodes::NamedFunction.new 'COALESCE', nodes
      end
    end


    class Constant < Stat
      def initialize value
        @value = value
      end

      def node
        Arel.sql(@value.to_s)
      end

      def dependencies
        Set.new
      end
    end

    class Volatile < Stat
      def initialize &block
        @proc = Proc.new(&block)
      end

      def node
        Arel.sql(@proc.call.to_s)
      end

      def dependencies
        Set.new
      end
    end

    class BinaryCombinator < Stat
      def initialize left, right
        @left = to_stat left
        @right = to_stat right
      end

      def dependencies
        @left.dependencies + @right.dependencies
      end
    end

    # Arithmetic
    class Addition < BinaryCombinator
      def node
        Arel::Nodes::Addition.new @left.node, @right.node
      end
    end

    class Subtraction < BinaryCombinator
      def node
        Arel::Nodes::Subtraction.new @left.node, @right.node
      end
    end

    class Multiplication < BinaryCombinator
      def node
        Arel::Nodes::Multiplication.new @left.node, @right.node
      end
    end

    class Division < BinaryCombinator
      def node
        Arel::Nodes::Division.new @left.node, @right.node
      end
    end
  end

  # Helper methods
  def self.volatile &block
    Stats::Volatile.new(&block)
  end
end
