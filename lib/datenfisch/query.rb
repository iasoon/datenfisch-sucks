require 'datenfisch/primary_query'
require 'datenfisch/query_modifiers'
require 'datenfisch/model'
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
      model = get_model
      if model
        res = model.find_by_sql arel
        # include relations
        ActiveRecord::Associations::Preloader.new.preload(res, get_included)
        res
      end
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

    def get_included
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
