module Datenfisch

  class Stat

    def as name
      AliasedStat.new name, self
    end

    private
    def self.define_combinator name, &combination_proc
      define_method name do |other|
        if other.is_a? Stat
          newnode = combination_proc.call node, other.node
          newdeps = dependencies | other.dependencies
        else
          newnode = combination_proc.call node, other
          newdeps = dependencies
        end
        AnonymousStat.new newnode, newdeps
      end
    end

    # basic arithmetic
    define_combinator :+ do |l,r| Arel::Nodes::Addition.new l, r end
    define_combinator :- do |l,r| Arel::Nodes::Subtraciton.new l, r end
    define_combinator :* do |l,r| Arel::Nodes::Multiplication.new l, r end
    define_combinator :/ do |l,r| Arel::Nodes::Division.new l, r end

  end

  class NamedStat < Stat

    def named_node
      Arel::Nodes::As.new(node, @name)
    end

  end

  class AliasedStat < Stat
    attr_reader :name

    def initialize name, stat
      @aliased = stat
      @name = name
    end

    def node
      @aliased.node
    end

    def named_node
      Arel::Nodes::As.new(node, @name)
    end

    def dependencies
      @aliased.dependencies
    end
  end

  class PrimaryStat < NamedStat
    attr_reader :name, :provider, :primary_node

    def initialize name, primary_node, provider
      @name = name
      @primary_node = primary_node.as(@name.to_s)
      @provider = provider
    end

    def node
      coalesce @provider.table[@name], 0
    end

    def dependencies
      Set.new.add self
    end

    # Todo: Do not use 0 as hardcoded default.
    def coalesce *nodes
      Arel::Nodes::NamedFunction.new 'COALESCE', nodes
    end

  end

  class SecondaryStat < NamedStat
    attr_reader :name, :node, :dependencies

    def initialize name, node, depends
      @name = name
      @node = node
      @dependencies = depends.to_set
    end

  end

  class AnonymousStat < Stat
    attr_reader :node, :dependencies

    def initialize node, depends
      @node = node
      @dependencies = depends.to_set
    end

    def name name
      SecondaryStat.new name, node, dependencies
    end
    alias_method :as, :name
  end

end
