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
            additions = grouping.select { |action, pos, _| action == '+' }
            deletions = grouping.select { |action, pos, _| action == '-' }

          last_pos = nil
          additions.each do |_action, pos, _|
            raise "Error" if last_pos && last_pos != pos-1
            last_pos = pos
          end


          last_pos = nil
          deletions.each do |_action, pos, _|
            raise "Error" if last_pos && last_pos != pos-1
            last_pos = pos
          end

          before_elements[deletions.first.position] = %(<del class="del">#{deletions.map(&:element).join(" ")}</del>) if deletions.length.positive?
          deletions[1..]&.each { |action, position, _| before_elements[position] = "" }

          pp "additions are: #{additions.map(&:element)}"

          if additions.length.positive?
            if deletions.first&.position == additions.first.position
              before_elements[additions.first.position] = %(#{before_elements[additions.first.position]}<ins class="ins ins-after">#{additions.map(&:element).join(" ")}</ins>)
            else
              before_elements[additions.first.position] = %(<ins class="ins ins-before">#{additions.map(&:element).join(" ")}</ins>#{before_elements[additions.first.position]})
            end
          end
        end

        ::Nokogiri::HTML.fragment(before_elements.reject(&:empty?).join(' '))
      end

      def priority
        1
      end
    end
  end
end
