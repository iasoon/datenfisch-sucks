module Datenfisch
  module Nodes
    module Convertions
      refine Node do
        def to_node
          self
        end
      end

      refine String do
        def to_node
          Literal.new self
        end
      end

      refine Numeric do
        def to_node
          Literal.new self.to_s
        end
      end

      refine Proc do
        def to_node
          Volatile.new self
        end
      end
    end
  end
end
