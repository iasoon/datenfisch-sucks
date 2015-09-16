module Datenfisch
  module Nodes
    def self.combinator &fun
      klass = Class.new Base
      klass.include Combinator
      klass.define_singleton_method :combine_arel, fun
      klass
    end

    module Combinator
      attr_reader :children

      def initialize *children
        #TODO: arity checks
        @children = children
      end

      def leaves
        children.map(&:leaves).concat
      end

      def arel
        self.class.combine_arel *children.map(&:arel)
      end
    end
  end
end
