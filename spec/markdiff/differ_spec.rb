require "markdiff"
require "nokogiri"
require "spec_helper"

RSpec.describe Markdiff::Differ do
  let(:after_node) do
    Nokogiri::HTML.fragment(after_string)
  end

  let(:before_node) do
    Nokogiri::HTML.fragment(before_string)
  end

  let(:differ) do
    described_class.new
  end

  describe "#render" do
    subject do
      differ.render(before_string, after_string)
    end

    context "with any valid arguments" do
      let(:after_string) do
        "<p>b</p>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns a Nokogiri::XML::Node" do
        expect(subject).to be_a Nokogiri::XML::Node
      end
    end

    context "with same node" do
      let(:after_string) do
        before_string
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns same node" do
        expect(subject.to_html).to eq before_node.to_html
      end
    end

    context "with different text node" do
      let(:after_string) do
        "<p>b</p>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq "<p><del>a</del><ins>b</ins></p>"
      end
    end

    context "with different tag name" do
      let(:after_string) do
        "<h1>a</h1>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq "<del><p>a</p></del><ins><h1>a</h1></ins>"
      end
    end

    context "with difference in nested node" do
      let(:after_string) do
        "<p><strong>a</strong></p>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq "<p><del>a</del><ins><strong>a</strong></ins></p>"
      end
    end

    context "with difference in sibling" do
      let(:after_string) do
        "<p>a</p><p>b</p>"
      end

      let(:before_string) do
        "<p>b</p>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq "<ins><p>a</p></ins><p>b</p>"
      end
    end

    context "with removing" do
      let(:after_string) do
        "<p>a</p>"
      end

      let(:before_string) do
        "<p>a</p><p>b</p>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq "<p>a</p><del><p>b</p></del>"
      end
    end

    context "with difference in table tag" do
      let(:after_string) do
        "<table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>c</td><td>e</td></tr></tbody></table>"
      end

      let(:before_string) do
        "<table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>c</td><td>d</td></tr></tbody></table>"
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq "<table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>c</td><td><del>d</del><ins>e</ins></td></tr></tbody></table>"
      end
    end

    context "with ul and li" do
      let(:after_string) do
        "<ul><li>a</li><li>b</li><li>a</li></ul>"
      end

      let(:before_string) do
        "<ul><li>a</li><li>a</li><li>a</li></ul>"
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq "<ul><li>a</li><li><del>a</del><ins>b</ins></li><li>a</li></ul>"
      end
    end

    context "with different href in a node" do
      let(:after_string) do
        '<a href="http://example.com/2">a</p>'
      end

      let(:before_string) do
        '<a href="http://example.com/1">a</p>'
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq '<a href="http://example.com/2" data-before-href="http://example.com/1">a</a>'
      end
    end

    context "with different level heading nodes" do
      let(:after_string) do
        "<h2>a</h2>"
      end

      let(:before_string) do
        "<h1>a</h1>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq '<h2 data-before-tag-name="h1">a</h2>'
      end
    end
  end
end
