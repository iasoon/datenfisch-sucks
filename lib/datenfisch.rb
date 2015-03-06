require "datenfisch/version"
require "datenfisch/provider"
require "datenfisch/model"

module Datenfisch
  def self.testvis
    Provider.build(Commit) do
      stat :additions, sum(:additions)
      stat :deletions, sum(:deletions)

      attr :datum, :date
      attr :coder_name, :github_name, through: :coder
    end
  end

  def self.test
    vis = testvis
    a = vis.additions
    d = vis.deletions
    c = (a+d).name 'changed'
    BaseQuery.new.select(c)
      .where(coder_name: 'Iasoon')
      .model(Coder)
      #.arel.to_sql
  end
end
