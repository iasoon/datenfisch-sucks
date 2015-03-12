require 'datenfisch/primary_query.rb'
module Datenfisch

  def self.query
    BaseQuery.new
  end

  class Query
    include Enumerable

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

    def joined_subqueries
      subqs = subqueries_for stats
      query_joiner.join_all(subqs).arel
    end

    def arel
      stats.inject joined_subqueries do |q, stat|
        q.project stat.named_node
      end
    end

    def run
      res = run_query
      # If a statted model is available, use it!
      statted_model = get_model.try(:const_get, "Statted")
      res.map! { |row| statted_model.new row } if statted_model
      res
    end

    def to_a
      run
    end

    def each &block
      to_a.each(&block)
    end

    def to_sql
      arel.to_sql
    end

    private
    def run_query
      ActiveRecord::Base.connection.execute(to_sql).map do |row|
        # Filter out positional arguments
        row.select { |k,v| k.is_a? String }
      end
    end

  end

  class BaseQuery < Query

    def stats
      Set.new
    end

    def query_joiner
      PrimaryQueryJoiner.new
    end

    def get_model
      nil
    end


    def subqueries_for stats
      stats.map(&:dependencies)
        .reduce(&:|)
        .group_by(&:provider)
        .map do |provider, statlist|
          provider.query.select(*statlist)
        end
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
      # Make sure we have got an ActiveRecord::Relation here
      @model = model.all
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

end
