require "markdiff"
require "nokogiri"
require "spec_helper"

RSpec.describe Markdiff::Differ do
  let(:differ) do
    described_class.new
  end

  describe "#render" do
    subject do
      differ.render(str1, str2)
    end

    let(:str1) do
      "<div>a</div>"
    end

    let(:str2) do
      "<div>b</div>"
    end

    it "takes two HTML strings and returns a diff as a Nokogiri::XML::Document" do
      is_expected.to be_a Nokogiri::XML::Document
    end
  end
end
