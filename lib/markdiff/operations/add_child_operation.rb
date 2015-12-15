require "markdiff/operations/base"

module Markdiff
  module Operations
    class AddChildOperation < Base
      # @return [String]
      def inserted_node
        if @inserted_node.name == "li"
          @inserted_node["class"] = (@inserted_node["class"].to_s.split(/\s/) + ["added"]).join(" ")
          @inserted_node.inner_html = "<ins>#{@inserted_node.inner_html}</ins>"
          @inserted_node
        else
          "<ins>#{@inserted_node}</ins>"
        end
      end
    end
  end
end
