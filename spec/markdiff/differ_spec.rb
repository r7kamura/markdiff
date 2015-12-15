require "markdiff"
require "spec_helper"

RSpec.describe Markdiff::Differ do
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
        expect(subject.to_html).to eq before_string
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
        expect(subject.to_html).to eq '<div class="changed"><p><del>a</del><ins>b</ins></p></div>'
      end
    end

    context "with partial difference in text node" do
      let(:after_string) do
        "<p>aaa bbb aaa</p>"
      end

      let(:before_string) do
        "<p>aaa aaa aaa</p>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq '<div class="changed"><p>aaa <del>aaa</del><ins>bbb</ins> aaa</p></div>'
      end
    end

    context "with adding a new sibling" do
      let(:after_string) do
        "<p>a</p>\n\n<p>b</p>\n"
      end

      let(:before_string) do
        "<p>b</p>\n"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq "<ins><p>a</p></ins><ins>\n\n</ins><p>b</p>\n"
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
        expect(subject.to_html).to eq '<del><p>a</p></del><ins><h1>a</h1></ins>'
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
        expect(subject.to_html).to eq '<div class="changed"><p><del>a</del><ins><strong>a</strong></ins></p></div>'
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
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>c</td><td><del>d</del><ins>e</ins></td></tr></tbody></table></div>'
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
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li>a</li><li class="changed"><del>a</del><ins>b</ins></li><li>a</li></ul></div>'
      end
    end

    context "with removed li" do
      let(:after_string) do
        "<ul><li>a</li></ul>"
      end

      let(:before_string) do
        "<ul><li>a</li><li>b</li></ul>"
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li>a</li><li class="removed"><del>b</del></li></ul></div>'
      end
    end

    context "with added child li" do
      let(:after_string) do
        "<ul><li>a</li><li>b</li></ul>"
      end

      let(:before_string) do
        "<ul><li>a</li></ul>"
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li>a</li><li class="added"><ins>b</ins></li></ul></div>'
      end
    end

    context "with removed and added li" do
      let(:after_string) do
        "<ul><li>c</li><li>d</li></ul>"
      end

      let(:before_string) do
        "<ul><li>a</li><li>b</li></ul>"
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li class="changed"><del>a</del><ins>c</ins></li><li class="changed"><del>b</del><ins>d</ins></li></ul></div>'
      end
    end

    context "with added sibling li" do
      let(:after_string) do
        "<ul><li>a</li><li>b</li></ul>"
      end

      let(:before_string) do
        "<ul><li>b</li></ul>"
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li class="added"><ins>a</ins></li><li>b</li></ul></div>'
      end
    end

    context "with different href in a node" do
      let(:after_string) do
        '<p><a href="http://example.com/2">a</a></p>'
      end

      let(:before_string) do
        '<p><a href="http://example.com/1">a</a></p>'
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq '<div class="changed"><p><a href="http://example.com/2" data-before-href="http://example.com/1">a</a></p></div>'
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
        expect(subject.to_html).to eq '<div class="changed"><h2 data-before-tag-name="h1">a</h2></div>'
      end
    end

    context "with replaced operation target node" do
      let(:after_string) do
        "<h1>c</h1>d"
      end

      let(:before_string) do
        "a<p>b</p>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq '<ins><h1>c</h1></ins><del>a</del><ins>d</ins><del><p>b</p></del>'
      end
    end

    context "with tasklist" do
      let(:after_string) do
        '<ul><li><input type="checkbox" checked> a</li></ul>'
      end

      let(:before_string) do
        '<ul><li><input type="checkbox"> a</li></ul>'
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li class="changed"><del><input type="checkbox"></del><ins><input type="checkbox" checked></ins> a</li></ul></div>'
      end
    end

    context "with prepending node" do
      let(:after_string) do
        "<h2>added</h2>\n\n<h2>a</h2>\n\n<p>b</p>\n"
      end

      let(:before_string) do
        "<h2>a</h2>\n\n<p>b</p>\n"
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq "<ins><h2>added</h2></ins><ins></ins><h2>a</h2><p>b</p>"
      end
    end
  end
end
