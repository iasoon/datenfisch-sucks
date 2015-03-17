require 'datenfisch/primary_query.rb'
require 'datenfisch/query_modifiers.rb'
module Datenfisch

  def self.query
    BaseQuery.new
  end

  class Query
    include Enumerable

    def joined_subqueries
      subqs = subqueries_for stats
      query_joiner.join_all(subqs).arel
    end

    def arel
      projected = stats.inject joined_subqueries do |q, stat|
        q.project stat.named_node
      end
      projected.order(*get_ordering)
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

    def get_ordering
      []
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

end
