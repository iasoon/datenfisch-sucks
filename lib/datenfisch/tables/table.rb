require 'datenfisch/tables/base'
module Datenfisch
  module Tables
    class Table < Base
      def initialize model
        @table = model.arel_table
      end

      def arel_table
        @table
      end

      def arel
        arel_table
      end

      def hash
        @table.hash
      end
    end
  end
end
