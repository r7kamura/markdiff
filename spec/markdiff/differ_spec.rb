require "active_support/core_ext/string/strip"
require "markdiff"
require "nokogiri"
require "spec_helper"

RSpec.describe Markdiff::Differ do
  let(:differ) do
    described_class.new
  end

  describe "#diff" do
    subject do
      differ.diff(before_node, after_node)
    end

    let(:after_node) do
      Nokogiri::HTML.fragment(after_string)
    end

    let(:before_node) do
      Nokogiri::HTML.fragment(before_string)
    end

    context "with any valid arguments" do
      let(:after_string) do
        "<p>b</p>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns a patch as an Array of Hash" do
        is_expected.to be_an Array
      end
    end

    context "with different text node" do
      let(:after_string) do
        "<p>b</p>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns :remove and :prepend_child operations" do
        expect(subject[0][:node]).to be_text
        expect(subject[0][:type]).to eq :remove
        expect(subject[1][:node]).to be_text
        expect(subject[1][:type]).to eq :prepend_child
      end
    end

    context "with same node" do
      let(:after_string) do
        before_string
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns empty patch" do
        expect(subject).to be_empty
      end
    end

    context "with different tag name" do
      let(:after_string) do
        "<h1>a</h1>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns :remove and :prepend_child operations" do
        expect(subject[0][:node].name).to eq "p"
        expect(subject[0][:type]).to eq :remove
        expect(subject[1][:node].name).to eq "h1"
        expect(subject[1][:type]).to eq :prepend_child
      end
    end

    context "with difference in nested node" do
      let(:after_string) do
        "<p><strong>a</strong></p>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns :remove and :prepend_child operations" do
        expect(subject[0][:node]).to be_text
        expect(subject[0][:type]).to eq :remove
        expect(subject[1][:node].name).to eq "strong"
        expect(subject[1][:type]).to eq :prepend_child
      end
    end

    context "with difference in sibling" do
      let(:after_string) do
        "<p>a</p><p>b</p>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns :add_next_sibling operation" do
        expect(subject[0][:type]).to eq :add_next_sibling
      end
    end

    context "with removing" do
      let(:after_string) do
        "<p>a</p>"
      end

      let(:before_string) do
        "<p>a</p><p>b</p>"
      end

      it "returns :remove operation" do
        expect(subject[0][:type]).to eq :remove
      end
    end

    context "with difference in table tag" do
      let(:after_string) do
        "<table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>c</td><td>e</td></tr></tbody></table>"
      end

      let(:before_string) do
        "<table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr><td>c</td><td>d</td></tr></tbody></table>"
      end

      it "returns expected operations" do
        expect(subject[0][:node]).to be_text
        expect(subject[0][:type]).to eq :remove
        expect(subject[1][:node]).to be_text
        expect(subject[1][:type]).to eq :prepend_child
      end
    end
  end

  describe "#render" do
    before do
      skip # Not implemented yet
    end

    subject do
      differ.render(before_string, after_string)
    end

    context "with two HTML strings as arguments" do
      let(:before_string) do
        "<p>a</p>"
      end

      let(:after_string) do
        "<p>b</p>"
      end

      it "returns a diff as a Nokogiri::XML::Node" do
        is_expected.to be_a Nokogiri::XML::Node
      end
    end

    context "with same HTML strings" do
      let(:before_string) do
        "<p>a</p>"
      end

      let(:after_string) do
        before_string
      end

      it "returns original string" do
        expect(subject.to_html.rstrip).to eq before_string
      end
    end

    context "with different paragraphs" do
      let(:before_string) do
        "<p>a</p>"
      end

      let(:after_string) do
        "<p>b</p>"
      end

      it "returns del and ins elements" do
        expect(subject.to_html).to eq <<-EOS.strip_heredoc.rstrip
          <ins><p>b</p></ins><del><p>a</p></del>
        EOS
      end
    end

    context "with same and different paragraphs" do
      let(:before_string) do
        "<p>a</p><p>b</p>"
      end

      let(:after_string) do
        "<p>a</p><p>c</p>"
      end

      it "returns del and ins elements" do
        expect(subject.to_html).to eq <<-EOS.strip_heredoc.rstrip
          <p>a</p><del><p>b</p></del><ins><p>c</p></ins>
        EOS
      end
    end

    context "with intermediate inserts" do
      let(:before_string) do
        "<p>a</p><p>d</p>"
      end

      let(:after_string) do
        "<p>a</p><p>b</p><p>c</p><p>d</p>"
      end

      it "inserts elements" do
        expect(subject.to_html).to eq <<-EOS.strip_heredoc.rstrip
          <p>a</p><ins><p>b</p></ins><ins><p>c</p></ins><p>d</p>
        EOS
      end
    end
  end
end
