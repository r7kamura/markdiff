require "markdiff/operations/base"

module Markdiff
  module Operations
    class AddPreviousSiblingOperation < Base
      # @return [String]
      def inserted_node
        "<ins>#{@inserted_node}</ins>"
      end
    end
  end
end
