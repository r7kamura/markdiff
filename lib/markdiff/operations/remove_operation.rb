require "markdiff/operations/base"

module Markdiff
  module Operations
    class RemoveOperation < Base
      # @return [String]
      def inserted_node
        if target_node.name == "li"
          target_node["class"] = "removed"
          target_node.inner_html = "<del>#{target_node.inner_html}</del>"
          target_node
        else
          "<del>#{target_node}</del>"
        end
      end
    end
  end
end
