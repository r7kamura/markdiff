require "active_support/core_ext/string/strip"
require "markdiff"
require "nokogiri"
require "spec_helper"

RSpec.describe Markdiff::Differ do
  let(:differ) do
    described_class.new
  end

  describe "#render" do
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
          <p>a</p><ins><p>c</p></ins><del><p>b</p></del>
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
