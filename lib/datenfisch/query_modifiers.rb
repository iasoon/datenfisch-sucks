module Datenfisch
  class Query

    def select(*stats)
      SelectModifier.new self, stats
    end

    def where(*args, **named_args)
      WhereModifier.new self, args, named_args
    end

    def group(field)
      GroupModifier.new self, field
    end

    def model(model, inner_join: false)
      if inner_join
        join_type = Arel::Nodes::InnerJoin
      else
        join_type = Arel::Nodes::OuterJoin
      end
      ModelModifier.new self, model, join_type
    end

    def order(*ordering)
      if ordering.last.is_a? Hash
        unhashed = ordering.pop.map do |k,v|
          if [:desc, :DESC, 'desc', 'DESC'].include? v
            Arel::Nodes::Descending.new Arel.sql(k.to_s)
          else
            k
          end
        end
        ordering = ordering.concat unhashed
      end
      OrderModifier.new self, ordering
    end

    def includes(*relations)
      IncludeModifier.new self, relations
    end

  end

  class QueryModifier < Query
    def self.pass_method name
      define_method name do
        @modified.send name
      end
    end

    def self.pass_methods *names
      names.each do |name|
        pass_method name
      end
    end

    def initialize modified
      @modified = modified
    end

    pass_methods :query_joiner, :stats, :get_model, :get_ordering,
      :get_included

    def subqueries_for stats
      @modified.subqueries_for stats
    end
  end

  class SelectModifier < QueryModifier
    def initialize modified, stats
      super modified
      @stats = stats.to_set
    end

    def stats
      @modified.stats | @stats
    end
  end

  class WhereModifier < QueryModifier
    def initialize modified, args, named_args
      super(modified)
      @args = args
      @named_args = named_args
    end

    def subqueries_for stats
      @modified.subqueries_for(stats).map do |q|
        q.where(*@args, **@named_args)
      end
    end
  end

  class GroupModifier < QueryModifier

    def initialize modified, group_attr
      super modified
      @group_attr = group_attr
    end

    def query_joiner
      PrimaryQueryJoiner.new @group_attr
    end

    def subqueries_for stats
      @modified.subqueries_for(stats).map do |q|
        q.group(@group_attr)
      end
    end
  end

  class ModelModifier < QueryModifier
    def initialize modified, model, join_type
      super modified
      @model = model
      @join_type = join_type
    end

    def query_joiner
      ModelJoiner.new @model, @join_type
    end

    def get_model
      @model
    end

    def subqueries_for stats
      @modified.subqueries_for(stats).map do |q|
        q.group(@model.name.downcase.concat('_id'))
      end
    end
  end

  class OrderModifier < QueryModifier
    def initialize modified, ordering
      super modified
      @ordering = ordering
    end

    def get_ordering
      @modified.get_ordering.concat @ordering
    end
  end

  class IncludeModifier < QueryModifier
    def initialize modified, included
      super modified
      @included = included
    end

    def get_included
      @modified.get_included + @included
    end
  end
end
