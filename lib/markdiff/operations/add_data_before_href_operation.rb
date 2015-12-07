require "markdiff/operations/base"

module Markdiff
  module Operations
    class AddDataBeforeHrefOperation < Base
      attr_reader :after_href

      def initialize(after_href:, **args)
        super(**args)
        @after_href = after_href
      end
    end
  end
end
