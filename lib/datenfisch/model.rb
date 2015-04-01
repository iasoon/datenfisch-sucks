require 'delegate'
module Datenfisch

  module Model
    def stat name, stat
      # Alias stat with given name
      stat = stat.as name

      # Add stat to hash
      self.const_get("Stats")[name.to_sym] = stat

      # fixate class
      #model_id = self.name.downcase.concat('_id')

      # Define stat getter
      #define_method name do |*args, **named_args|
        #query = Datenfisch::query.select(stat)
          #.where(model_id => id)
          #.where(*args, **named_args)

        ## Extract result
        #query.run.first[stat.name.to_s]
      #end

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
