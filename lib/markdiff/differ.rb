require "nokogiri"

module Markdiff
  class Differ
    # @param [String] before_string
    # @param [String] after_string
    # @return [Nokogiri::XML::Document]
    def render(before_string, after_string)
      before_document = ::Nokogiri::HTML.fragment(before_string)
      after_document = ::Nokogiri::HTML.fragment(after_string)

      # create map
      identity_map = {}
      before_document.children.each_with_index do |before_child, before_index|
        after_document.children.each_with_index do |after_child, after_index|
          if calculate_key(before_child) == calculate_key(after_child)
            identity_map[before_index] = after_index
          end
        end
      end
      inverted_identity_map = identity_map.invert

      # create patch
      patch = {
        appends: [],
        removes: [],
      }
      before_document.children.each_with_index do |before_child, before_index|
        unless identity_map[before_index]
          patch[:removes] << before_index
        end
      end
      last_identified_after_index = nil
      after_document.children.each_with_index do |after_child, after_index|
        if inverted_identity_map[after_index]
          last_identified_after_index = after_index
        else
          patch[:appends] << { index: after_index, previous_index: last_identified_after_index }
        end
      end

      # apply patch
      before_document.children.each_with_index do |before_child, before_index|
        if patch[:removes].include?(before_index)
          before_child = before_child.replace("<del>#{before_child.to_html}</del>")
        end
        patch[:appends].reverse.each do |operation|
          case inverted_identity_map[operation[:previous_index]]
          when nil
            if before_index == 0
              after_child = after_document.children[operation[:index]]
              before_document.prepend_child("<ins>#{after_child.to_html}</ins>")
            end
          when before_index
            after_child = after_document.children[operation[:index]]
            before_child.add_next_sibling("<ins>#{after_child}</ins>")
          end
        end
      end
      return before_document
    end

    private

    # @param [Nokogiri::XML::Node] node
    # @return [String]
    def calculate_key(node)
      node.to_html.gsub(/\s+/, " ")
    end
  end
end
