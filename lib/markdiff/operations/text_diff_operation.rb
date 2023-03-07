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
        before_elements = target_node.to_s.split(' ')
        after_elements = @after_node.to_s.split(' ')

        groupings = ::Diff::LCS.sdiff(before_elements, after_elements).slice_when {|prev, cur| prev.action != cur.action }

        output = groupings.map do |grouping|
          case grouping.first.action
          when "="
            grouping.map(&:new_element).join(" ")
          when "-"
            "<del class=\"del\">#{grouping.map(&:old_element).join(" ")}</del>"
          when "+"
            "<ins class=\"ins ins-before\">#{grouping.map(&:new_element).join(" ")}</ins>"
          when "!"
            "<del class=\"del\">#{grouping.map(&:old_element).join(" ")}</del><ins class=\"ins ins-after\">#{grouping.map(&:new_element).join(" ")}</ins>"
          end
        end

        ::Nokogiri::HTML.fragment(output.join(' '))
      end

      def priority
        1
      end
    end
  end
end
