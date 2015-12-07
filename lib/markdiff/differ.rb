require "nokogiri"
require "markdiff/operations/add_child_operation"
require "markdiff/operations/add_data_before_href_operation"
require "markdiff/operations/add_data_before_tag_name_operation"
require "markdiff/operations/add_previous_sibling_operation"
require "markdiff/operations/remove_operation"

module Markdiff
  class Differ
    # Apply a given patch to a given node
    # @param [Array<Markdiff::Operations::Base>] operations
    # @param [Nokogiri::XML::Node] node
    # @return [Nokogiri::XML::Node] Converted node
    def apply_patch(operations, node)
      operations.each do |operation|
        case operation
        when ::Markdiff::Operations::AddChildOperation
          operation.target_node.add_child(operation.inserted_node)
        when ::Markdiff::Operations::AddDataBeforeHrefOperation
          operation.target_node["data-before-href"] = operation.target_node["href"]
          operation.target_node["href"] = operation.after_href
        when ::Markdiff::Operations::AddDataBeforeTagNameOperation
          operation.target_node["data-before-tag-name"] = operation.target_node.name
          operation.target_node.name = operation.after_tag_name
        when ::Markdiff::Operations::AddPreviousSiblingOperation
          operation.target_node.add_previous_sibling(operation.inserted_node)
        when ::Markdiff::Operations::RemoveOperation
          operation.target_node.replace(operation.inserted_node)
        end
      end
      node
    end

    # Creates a patch from given two nodes
    # @param [Nokogiri::XML::Node] before_node
    # @param [Nokogiri::XML::Node] after_node
    # @return [Array<Markdiff::Operations::Base>] operations
    def create_patch(before_node, after_node)
      if before_node.to_html == after_node.to_html
        []
      else
        create_patch_from_children(before_node, after_node)
      end
    end

    # Utility method to do both creating and applying a patch
    # @param [String] before_string
    # @param [String] after_string
    # @return [Nokogiri::XML::Node] Converted node
    def render(before_string, after_string)
      before_node = ::Nokogiri::HTML.fragment(before_string)
      after_node = ::Nokogiri::HTML.fragment(after_string)
      patch = create_patch(before_node, after_node)
      apply_patch(patch, before_node)
    end

    private

    # 1. Create identity map and collect patches from descendants
    #   1-1. Detect exact-matched nodes
    #   1-2. Detect partial-matched nodes and recursively walk through its children
    # 2. Create remove operations from identity map
    # 3. Create insert operations from identity map
    # 4. Return operations as a patch
    #
    # @param [Nokogiri::XML::Node] before_node
    # @param [Nokogiri::XML::Node] after_node
    # @return [Array<Markdiff::Operations::Base>] operations
    def create_patch_from_children(before_node, after_node)
      operations = []
      identity_map = {}
      inverted_identity_map = {}

      # Exactly matching
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

      # Partial matching
      before_node.children.each do |before_child|
        if identity_map[before_child]
          next
        end
        after_node.children.each do |after_child|
          next if inverted_identity_map[after_child]
          next if before_child.text?
          if before_child.name == after_child.name
            if detect_href_difference(before_child, after_child)
              operations << ::Markdiff::Operations::AddDataBeforeHrefOperation.new(after_href: after_child["href"], target_node: before_child)
            end
            identity_map[before_child] = after_child
            inverted_identity_map[after_child] = before_child
            operations += create_patch(before_child, after_child)
          elsif detect_heading_level_difference(before_child, after_child)
            operations << ::Markdiff::Operations::AddDataBeforeTagNameOperation.new(after_tag_name: after_child.name, target_node: before_child)
            identity_map[before_child] = after_child
            inverted_identity_map[after_child] = before_child
          end
        end
      end

      before_node.children.each do |before_child|
        unless identity_map[before_child]
          operations << ::Markdiff::Operations::RemoveOperation.new(target_node: before_child)
        end
      end

      after_node.children.each do |after_child|
        unless inverted_identity_map[after_child]
          right_node = after_child.next_sibling
          loop do
            case
            when inverted_identity_map[right_node]
              operations << ::Markdiff::Operations::AddPreviousSiblingOperation.new(inserted_node: after_child, target_node: inverted_identity_map[right_node])
              break
            when right_node.nil?
              operations << ::Markdiff::Operations::AddChildOperation.new(inserted_node: after_child, target_node: before_node)
              break
            else
              right_node = right_node.next_sibling
            end
          end
        end
      end

      operations
    end

    # @param [Nokogiri::XML::Node] before_node
    # @param [Nokogiri::XML::Node] after_node
    # @return [false, true] True if given 2 nodes are both hN nodes and have different N (e.g. h1 and h2)
    def detect_heading_level_difference(before_node, after_node)
      before_node.name != after_node.name &&
      %w[h1 h2 h3 h4 h5 h6].include?(before_node.name) &&
      %w[h1 h2 h3 h4 h5 h6].include?(after_node.name) &&
      before_node.inner_html == after_node.inner_html
    end

    # @param [Nokogiri::XML::Node] before_node
    # @param [Nokogiri::XML::Node] after_node
    # @return [false, true] True if given 2 nodes are both "a" nodes and have different href attributes
    def detect_href_difference(before_node, after_node)
      before_node.name == "a" &&
      after_node.name == "a" &&
      before_node["href"] != after_node["href"] &&
      before_node.inner_html == after_node.inner_html
    end
  end
end
