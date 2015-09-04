module Datenfisch
  module Utils
    def self.query
      Arel::SelectManager.new(ActiveRecord::Base)
    end
  end
end
