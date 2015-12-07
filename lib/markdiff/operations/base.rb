module Markdiff
  module Operations
    class Base
      # @return [Nokogiri::XML::Node]
      attr_reader :target_node

      # @param [Nokogiri::XML::Node, nil] inserted_node
      # @param [Nokogiri::XML::Node] target_node
      def initialize(inserted_node: nil, target_node:)
        @inserted_node = inserted_node
        @target_node = target_node
      end
    end
  end
end
