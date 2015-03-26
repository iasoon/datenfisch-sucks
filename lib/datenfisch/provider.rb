require 'datenfisch/dsl'
require 'datenfisch/stat'
require 'datenfisch/query'
require 'datenfisch/utils'

module Datenfisch

  class Provider
    extend DSL
    attr_reader :attributes, :stats, :table, :model

    dsl do
      def stat name, node
        name = name.to_sym
        create_stat name, node
      end

      def attr name, target=name, through: nil
        self.attributes[name] = Attribute.new target, through: through
      end

      def sum arg
        Arel::Nodes::Sum.new [to_node(arg)]
      end

      def count
        Arel::Nodes::Count.new [Arel.star]
      end

      # mysql functions
      def ln arg
        Arel::Nodes::NamedFunction.new 'LN', [to_node(arg)]
      end

      def a name
        self.model.arel_table[name]
      end

      # typecasts
      def cast arg, type
        Arel::Nodes::NamedFunction.new 'CAST',
          [Arel::Nodes::As.new(to_node(arg), to_node(type))]
      end

      def to_node arg
        case arg
        when Symbol
          arg
        when String
          Arel::Nodes::SqlLiteral.new arg
        else
          if arg.is_a? Arel::Node
            arg
          else
            throw "Cannot convert argument to node"
          end
        end
      end
    end

    def initialize model
      @model = model
      @table = Arel::Table.new(table_alias)
      @attributes = {}
    end

    def create_stat name, node
      stat = PrimaryStat.new name, node, self
      define_singleton_method name do
        stat
      end
    end

    def query
      PrimaryQuery.new self
    end

    def table_alias
      # Sexatrigecimal is fun.
      't' + hash.abs.to_s(36)
    end

    def [] name
      @table[name]
    end

  end

  class Attribute
    attr_reader :name, :through

    def initialize name, through: nil
      @name = name.to_sym
      @through = through.try(:to_sym)
    end

    def table
      Arel::Table.new(@through)
    end
  end
end
