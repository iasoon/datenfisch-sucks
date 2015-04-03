require "datenfisch/version"
require 'active_support/all'
require 'arel'
require "datenfisch/provider"
require "datenfisch/model"
require "datenfisch/query_methods"

require "datenfisch/nodes/methods"
require "datenfisch/nodes/convertions"

module Datenfisch
  def self.provider model, &block
    Provider.build model, &block
  end


  using Nodes::Convertions
  def self.test
    3.to_node + 5
  end
end
