require 'datenfisch/nodes/combinator'
module Datenfisch
  module Nodes
    Equality = combinator {|l,r| Arel::Nodes::Equality.new l, r}

    class Base
      def eq other
        Equality.new self, other
      end
    end
  end
end
