module Specdiff::Plugin
  module ClassMethods
    def compatible?(a, b)
      a.type == id && b.type == id
    end
  end

  def self.included(plugin)
    plugin.extend(ClassMethods)
  end
end
