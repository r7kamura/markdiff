require "markdiff/operations/base"

module Markdiff
  module Operations
    class RemoveOperation < Base
      # @return [String]
      def inserted_node
        "<del>#{@target_node}</del>"
      end
    end
  end
end
