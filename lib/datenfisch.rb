require "datenfisch/version"
require "datenfisch/provider"
require "datenfisch/model"

module Datenfisch
  def self.provider model, &block
    Provider.build model, &block
  end
end
