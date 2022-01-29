require "diff/lcs"
require "nokogiri"
require "markdiff/operations/base"

module Markdiff
  module Operations
    class TextDiffOperation < Base
      # @param [Nokogiri::XML::Node] after_node
      def initialize(after_node:, **args)
        super(**args)
        @after_node = after_node
      end

      # @return [Nokogiri::XML::Node]
      def inserted_node
        before_elements = target_node.to_s.split(" ")
        after_elements = @after_node.to_s.split(" ")
        deleted_positions = []

        ::Diff::LCS.diff(before_elements, after_elements).flatten(1).each do |operation|
          type, position, element = *operation

          if type == "-"
            before_elements[position] = %(<del class="del">#{element}</del>)
            deleted_positions << position
          elsif type == "+"
            if deleted_positions.include?(position)
              before_elements[position] = "#{before_elements[position]}<ins>#{element}</ins>"
            else
              before_elements[position] = "<ins>#{element}</ins> #{before_elements[position]}"
            end
          else
            raise "Unhandled type: #{type}"
          end
        end

        ::Nokogiri::HTML.fragment(before_elements.join(" "))
      end

      def priority
        1
      end
    end
  end
end
