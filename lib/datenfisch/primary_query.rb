module Datenfisch

  # Simple query wrapper
  class PrimaryQuery
    attr_reader :provider

    def initialize provider, query = provider.model
      @provider = provider
      @query = query
    end

    def select(*stats)
      new_query = stats.inject(@query) do |q, stat|
        q.select stat.primary_node
      end
      PrimaryQuery.new @provider, new_query
    end

    def where(*args, **hash)
      PrimaryQuery.new @provider, @query.where(*args, **hash)
    end

    def group(field_name)
      field = @provider.model.arel_table[field_name]
      aliased_field = Arel::Nodes::As.new field, field_name
      PrimaryQuery.new @provider, @query.select(aliased_field).group(field)
    end

    def relation_table rel_name
      RelationTable.new @provider.model, rel_name
    end

    def arel
      arel = @query.arel
      ast = arel.ast

      # Filter node that should be replaced
      to_replace = ast.grep(Arel::Attribute)
        .select { |a| @provider.attributes.has_key? a.name.to_sym }

      # Get tables that should be included
      relation_tables = to_replace.map do |a|
        @provider.attributes[a.name.to_sym].through
      end.compact.to_set.inject({}) do |hash, rel_name|
        hash.update rel_name => relation_table(rel_name)
      end

      # Replace attribute aliases
      to_replace.each do |a|
        attr = @provider.attributes[a.name.to_sym]
        if attr # It is possible that this attribute was already modified
          a.name = attr.name
          a.relation = relation_tables[attr.through].table if attr.through
        end
      end

      # Join queries
      joined_query = relation_tables.values
        .inject(@query.arel) do |query, relation_table|
          relation_table.join_with query
        end

      joined_query.as @provider.table_alias
    end
  end

  class RelationTable
    attr_reader :table

    def initialize model, rel_name
      @model = model
      @relation = model.reflections[rel_name]
      @table = @relation.klass.arel_table.clone
      @table.table_alias = rel_name.to_s.concat("_top4")
    end

    def join_condition
      @model.arel_table[@relation.foreign_key]
        .eq @table[@relation.klass.primary_key]
    end

    def join_with query
      query.join(@table).on(join_condition)
    end
  end

  class QueryJoiner
    attr_reader :ast
    alias_method :arel, :ast

    # Do everything
    def join_all queries
      first, *rest = queries
      join_first_table first
      rest.each { |q| join q }
      self
    end

    def join other
      if @join_attr
        @ast = ast.join(other.arel, Arel::Nodes::OuterJoin).on join_condition(other)
      else
        @ast = @ast.join(other.arel)
      end
      self
    end

    def join_condition other
      base_join_attr.eq other.provider[@join_attr]
    end
  end

  class PrimaryQueryJoiner < QueryJoiner

    def initialize join_attr = nil
      @join_attr = join_attr
      @ast = Arel::Table.new('dummy')
    end

    # Arel please
    def join_first_table table
      @base_provider = table.provider
      @ast = @ast.from(table.arel)

      # Select field on which we joined
      if @join_attr
        named_join_attr = Arel::Nodes::As.new(
          @base_provider[@join_attr], @join_attr.to_s
        )
        @ast = @ast.project named_join_attr
      end
    end

    def base_join_attr
      @base_provider[@join_attr]
    end
  end

  class ModelJoiner < QueryJoiner
    def initialize model_query
      @model_query = model_query
      @ast = model_query.arel
      @join_attr = model_query.name.downcase.concat('_id')
    end

    # This makes sense
    def join_first_table table
      join table
    end

    def base_join_attr
      @model_query.arel_table[@model_query.primary_key]
    end
  end

end
