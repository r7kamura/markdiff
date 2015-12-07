require "markdiff/operations/base"

module Markdiff
  module Operations
    class AddDataBeforeTagNameOperation < Base
      attr_reader :after_tag_name

      def initialize(after_tag_name:, **args)
        super(**args)
        @after_tag_name = after_tag_name
      end
    end
  end
end
