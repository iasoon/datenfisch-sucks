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

    def model(model)
      ModelModifier.new self, model
    end

    def order(*ordering)
      if ordering.last.is_a? Hash
        unhashed = ordering.pop.map do |k,v|
          if [:desc, :DESC, 'desc', 'DESC'].include? v
            # This should be an attribute identifier, not a literal string.
            # Arel does not support attributes without a table ( Or I'm just
            # plain silly)
            Arel::Nodes::Descending.new Arel.sql('"' + k.to_s + '"')
          else
            k
          end
        end
        ordering = ordering.concat unhashed
      end
      OrderModifier.new self, ordering
    end

  end

  class QueryModifier < Query

    def initialize modified
      @modified = modified
    end

    def query_joiner
      @modified.query_joiner
    end

    def stats
      @modified.stats
    end

    def get_model
      @modified.get_model
    end

    def get_ordering
      @modified.get_ordering
    end

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
    def initialize modified, model
      super modified
      @model = model
    end

    def query_joiner
      ModelJoiner.new @model
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
end
