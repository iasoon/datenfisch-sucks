require 'datenfisch/nodes/combinators'
require 'datenfisch/nodes/convertions'
module Datenfisch
  module Nodes
    module Helpers
      using Convertions

      def ln arg
        Logarithm.new arg.to_node
      end

    end
  end
end
