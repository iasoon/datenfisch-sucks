require 'datenfisch/primary_query'
require 'datenfisch/query_modifiers'
require 'datenfisch/model'
require 'datenfisch/statted_model'
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
      klass = get_model
      if klass
        # this seems a little hacky
        klass.extend Statted if not klass.is_a? Statted
        res.map! { |row| klass.instantiate_with_stats row }
      end
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
      resultset = ActiveRecord::Base.connection.execute(to_sql)
      resultset.map do |res|
        Hash[resultset.fields.zip res]
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
