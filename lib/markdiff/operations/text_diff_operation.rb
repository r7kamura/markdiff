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

        ::Diff::LCS.diff(before_elements, after_elements)
          .each do |grouping|
            insertions = grouping.select { |diff| diff.action == '+' }
            deletions = grouping.select { |diff| diff.action == '-' }
            deletion_start = deletions.first&.position
            insertion_start = insertions.first&.position

            before_elements[deletion_start] = %(<del class="del">#{deletions.map(&:element).join(" ")}</del>) if deletion_start
            deletions[1..]&.each { |diff| before_elements[diff.position] = "" }

            before_elements[insertion_start] = if deletion_start == insertion_start
              %(#{before_elements[insertion_start]}<ins class="ins ins-after">#{insertions.map(&:element).join(" ")}</ins>)
            else
              %(<ins class="ins ins-before">#{insertions.map(&:element).join(" ")}</ins>#{before_elements[insertion_start]})
            end if insertion_start
        end

        ::Nokogiri::HTML.fragment(before_elements.reject(&:empty?).join(' '))
      end

      def priority
        1
      end
    end
  end
end
