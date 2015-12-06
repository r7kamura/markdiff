require "nokogiri"

module Markdiff
  class Differ
    def apply(patch, node)
      patch.each do |operation|
        case operation[:type]
        when :add_previous_sibling
          operation[:right_node].add_previous_sibling("<ins>#{operation[:node]}</ins>")
        when :prepend_child
          operation[:parent_node].add_child("<ins>#{operation[:node]}</ins>")
        when :remove
          operation[:node].replace("<del>#{operation[:node]}</del>")
        else
          raise "Unknown operation type: #{operation[:type].inspect}"
        end
      end
      node
    end

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

    private

    # Takes 2 parent nodes and recursively compare their children.
    #
    # @note There are 3 types of patch operations:
    #
    # - add_previous_sibling
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
          right_node = after_child.next_sibling
          loop do
            case
            when inverted_identity_map[right_node]
              patch << { right_node: inverted_identity_map[right_node], node: after_child, type: :add_previous_sibling }
              break
            when right_node.nil?
              patch << { parent_node: before_node, node: after_child, type: :prepend_child }
              break
            else
              right_node = right_node.next_sibling
            end
          end
        end
      end

      patch
    end
  end
end
