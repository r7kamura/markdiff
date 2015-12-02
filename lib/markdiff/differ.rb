require "nokogiri"

module Markdiff
  class Differ
    def render(str1, str2)
      ::Nokogiri::XML::Document.new
    end
  end
end
