require 'delegate'
module Datenfisch

  module Model
    def stat name, stat
      # Alias stat with given name
      stat = stat.as name

      # Add stat to hash
      self.const_get("Stats")[name.to_sym] = stat

      # Define stat getter
      define_method name do |*args, **named_args|
        attributes[name.to_s] || stat.get(
          self.class.name.downcase.concat('_id') => self
        )
      end

      # Define getter for stat object
      define_singleton_method name do
        stat
      end

    end


    def self.extended model
      model.const_set "Stats", {}
    end

    def statted
      self.all.extending QueryMethods
    end

    delegate :with_stats, :only_with_stats, to: :statted
  end
end
