require 'delegate'

module Datenfisch

  module DSL

    def build *args, &block
      obj = self.new(*args)
      delegator = self.const_get('DSLDelegator').new(obj)
      if block.arity == 1
        block.call(delegator)
      else
        delegator.instance_eval(&block)
      end
      obj
    end

    def dsl &block
      delegator_klass = Class.new(SimpleDelegator, &block)
      self.const_set('DSLDelegator', delegator_klass)
    end

  end
end
