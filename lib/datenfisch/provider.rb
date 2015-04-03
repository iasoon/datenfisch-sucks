require 'datenfisch/dsl'
require 'datenfisch/stat'
require 'datenfisch/nodes'
require 'datenfisch/query'

module Datenfisch

  class Provider
    extend DSL
    attr_reader :attributes, :stats, :table, :model

    dsl do
      include Nodes::Helpers

      def stat name, node
        name = name.to_sym
        create_stat name, node
      end

      def attr name, target=name, through: nil
        self.attributes[name] = Attribute.new target, through: through
      end

      def col name
        Nodes::Column.new self.model.arel_table, name
      end

      def count
        Nodes::Literal.new('*').count
      end
    end

    def initialize model
      @model = model
      @table = Arel::Table.new(table_alias)
      @attributes = {}
    end

    def create_stat name, node
      stat = Nodes::PrimaryStat.new name, node, self
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
