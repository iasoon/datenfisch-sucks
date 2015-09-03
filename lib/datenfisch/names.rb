module Datenfisch
  module Names
    def self.node obj
      'n' + obj.hash.abs.to_s(36)
    end

    def self.table obj
      't' + obj.hash.abs.to_s(36)
    end

    def self.aggregator obj
      'a' + obj.hash.abs.to_s(36)
    end
  end
end
