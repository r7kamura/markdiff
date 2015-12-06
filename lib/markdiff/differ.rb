require "nokogiri"

module Markdiff
  class Differ
    # Takes parent nodes and returns a patch as an Array of operations
    # @param [Nokogiri::XML::Node] before_node
    # @param [Nokogiri::XML::Node] after_node
    # @return [Array<Hash>] Patch
    def diff(before_node, after_node)
      if before_node.to_html == after_node.to_html
        []
      else
        diff_children(before_node, after_node)
      end
    end

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
      end
      before_document.children.each_with_index do |before_child, before_index|
        patch[:appends].reverse.each do |operation|
          case inverted_identity_map[operation[:previous_index]]
          when nil
            if before_index == 0
              after_child = after_document.children[operation[:index]]
              before_document.prepend_child("<ins>#{after_child.to_html}</ins>")
            end
          when before_index
            after_child = after_document.children[operation[:index]]
            target = before_child
            while target.next_element && target.next_element.matches?("del") do
              target = target.next_element
            end
            target.add_next_sibling("<ins>#{after_child}</ins>")
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

    # Takes 2 parent nodes and recursively compare their children.
    #
    # @note There are 3 types of patch operations:
    #
    # - add_next_sibling
    # - prepend_child
    # - remove
    #
    # @param [Nokogiri::XML::Node] before_node
    # @param [Nokogiri::XML::Node] after_node
    # @return [Array<Hash>] Patch
    def diff_children(before_node, after_node)
      patch = []
      identity_map = {}
      inverted_identity_map = {}
      before_node.children.each do |before_child|
        after_node.children.each do |after_child|
          if inverted_identity_map[after_child]
            next
          end
          if before_child.to_html == after_child.to_html
            identity_map[before_child] = after_child
            inverted_identity_map[after_child] = before_child
          end
        end
      end

      before_node.children.each do |before_child|
        if identity_map[before_child]
          next
        end
        after_node.children.each do |after_child|
          if inverted_identity_map[after_child]
            next
          end
          if before_child.name == after_child.name && !before_child.text?
            identity_map[before_child] = after_child
            inverted_identity_map[after_child] = before_child
            patch += diff(before_child, after_child)
          end
        end
      end

      before_node.children.each do |before_child|
        unless identity_map[before_child]
          patch << { node: before_child, type: :remove }
        end
      end

      after_node.children.each do |after_child|
        unless inverted_identity_map[after_child]
          left_node = after_child.previous
          loop do
            case
            when inverted_identity_map[left_node]
              patch << { left_node: left_node, node: after_child, type: :add_next_sibling }
              break
            when left_node.nil?
              patch << { parent_node: after_node, node: after_child, type: :prepend_child }
              break
            else
              left_node = left_node.previous
            end
          end
        end
      end

      patch
    end
  end
end
