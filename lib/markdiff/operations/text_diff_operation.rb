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
        last_deleted_pos = nil

        ::Diff::LCS.diff(before_elements, after_elements).flatten(1).each do |operation|
          type, position, element = *operation

          if type == "-"
            before_elements[position] = %(<del class="del">#{element}</del>)
            last_deleted_pos = position
          elsif type == "+"
            insert = "<ins>#{element}</ins>"

            if last_deleted_pos == position
              before_elements[position] = "#{before_elements[position]} #{insert}"
            else
              before_elements[position] = "#{insert} #{before_elements[position]}"
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
