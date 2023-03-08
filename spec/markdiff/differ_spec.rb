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
        expect(subject.to_html).to eq '<div class="changed"><p><del class="del">a</del><ins class="ins ins-after">b</ins></p></div>'
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
        expect(subject.to_html).to eq '<div class="changed"><p>aaa <del class="del">aaa</del><ins class="ins ins-after">bbb</ins> aaa</p></div>'
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
        expect(subject.to_html).to eq '<del class="del"><p>a</p></del><ins><h1>a</h1></ins>'
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
        expect(subject.to_html).to eq '<div class="changed"><p><del class="del">a</del><ins><strong>a</strong></ins></p></div>'
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
        expect(subject.to_html).to eq '<p>a</p><del class="del"><p>b</p></del>'
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
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><table><thead><tr><th>a</th><th>b</th></tr></thead><tbody><tr class="changed"><td>c</td><td><del class="del">d</del><ins class="ins ins-after">e</ins></td></tr></tbody></table></div>'
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
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li>a</li><li class="changed"><del class="del">a</del><ins class="ins ins-after">b</ins></li><li>a</li></ul></div>'
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
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li>a</li><li class="removed"><del class="del">b</del></li></ul></div>'
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
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li class="changed"><del class="del">a</del><ins class="ins ins-after">c</ins></li><li class="changed"><del class="del">b</del><ins class="ins ins-after">d</ins></li></ul></div>'
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
        expect(subject.to_html).to eq '<ins><h1>c</h1></ins><del class="del">a</del><ins class="ins ins-after">d</ins><del class="del"><p>b</p></del>'
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
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li class="changed"><del class="del"><input type="checkbox"></del><ins><input type="checkbox" checked></ins> a</li></ul></div>'
      end
    end

    context "with inserted word in the middle of the text" do
      let(:after_string) do
        "<div>Kurset skal give de studerende TEST procesforståelse samt teoretisk og praktisk erfaring.</div>"
      end
      let(:before_string) do
        "<div>Kurset skal give de studerende procesforståelse samt teoretisk og praktisk erfaring.</div>"
      end

      it "returns the expected patched text" do
        expect(subject.to_html)
          .to eq '<div class="changed"><div>Kurset skal give de studerende <ins class="ins ins-before">TEST</ins>procesforståelse samt teoretisk og praktisk erfaring.</div></div>'
      end
    end

    context "with added word at the beginning" do
      let(:after_string) do
        "Det Kurset skal give de studerende procesforståelse samt teoretisk og praktisk erfaring."
      end
      let(:before_string) do
        "Kurset skal give de studerende procesforståelse samt teoretisk og praktisk erfaring."
      end

      it "returns the expected patched node" do
        expect(subject.to_html)
          .to eq '<ins class="ins ins-before">Det</ins>Kurset skal give de studerende procesforståelse samt teoretisk og praktisk erfaring.'
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

    context "with classed li node" do
      let(:after_string) do
        '<ul><li class="a">b</li></ul>'
      end

      let(:before_string) do
        '<ul></ul>'
      end

      it "returns expected patched node" do
        expect(subject.to_html.gsub("\n", "")).to eq '<div class="changed"><ul><li class="a added"><ins>b</ins></li></ul></div>'
      end
    end

    context "with a sequence of AddChild operations" do
      let(:after_string) do
        "<p>b</p><p>c</p><p>d</p>"
      end

      let(:before_string) do
        "<p>a</p>"
      end

      it "returns expected patched node" do
        expect(subject.to_html).to eq '<div class="changed"><p><del class="del">a</del><ins class="ins ins-after">b</ins></p></div><ins><p>c</p></ins><ins><p>d</p></ins>'
      end
    end

    context "with insertion and deletion on same positions" do
      let(:after_string) { "JEG HEDDER Kurset give de studerende procesforståelse" }
      let(:before_string) { "Kurset skal give de studerende procesforståelse" }

      it 'returns expected patched node' do
        expect(subject.to_html).to eq '<ins class="ins ins-before">JEG HEDDER</ins>Kurset <del class="del">skal</del> give de studerende procesforståelse'
      end
    end

    context "with lots of changes" do
      let(:after_string) do
        "Der gælder for specialer udført ved Faculty of Natural Sciences og Faculty of Technical Sciences, Et Universitet. Hovedvejleder har det formelle ansvar for den faglige vejledning."
      end
      let(:before_string) do
        "Der gælder for specialer udført ved Science & Technology, Et Universitet. Hovedvejleder har det formelle ansvar for den faglige vejledning."
      end

      it "returns the expected patched note" do
        expect(subject.to_html).to eq 'Der gælder for specialer udført ved <del class="del">Science &amp; Technology,</del><ins class="ins ins-after">Faculty of Natural</ins> <ins class="ins ins-before">Sciences og Faculty of Technical Sciences,</ins>Et Universitet. Hovedvejleder har det formelle ansvar for den faglige vejledning.'
      end
    end

    context "with even more changes" do
      let(:after_string) do
        "De matematiske begreber i kurset kommer først og fremmest til at blive underbygget af små eksperimenter i programmeringssprogene php, Sage og ruby."
      end
      let(:before_string) do
        "De matematiske slettet begreber i kurset kommer først og fremmest til at blive underbygget af små eksperimenter i programmeringssprogene Sage og python."
      end

      it "returns the expected patched note" do
        expect(subject.to_html)
          .to eq 'De matematiske <del class="del">slettet</del> begreber i kurset kommer først og fremmest til at blive underbygget af små eksperimenter i programmeringssprogene <ins class="ins ins-before">php,</ins>Sage og <del class="del">python.</del><ins class="ins ins-after">ruby.</ins>'
      end
    end

    context "with weird changes" do
      let(:after_string) do
        "De matematiske begreber kommer først og fremmest i kurset vil blive underbygget af små eksperimenter i programmeringssprogene php, Sage og ruby."
      end
      let(:before_string) do
        "De matematiske asd begreber i kurset vil blive underbygget af små eksperimenter i programmeringssprogene Sage og python."
      end

      it "returns the expected patched note" do
        expect(subject.to_html).to eq 'De matematiske <del class="del">asd</del> begreber <ins class="ins ins-before">kommer først og fremmest</ins>i kurset vil blive underbygget af små eksperimenter i programmeringssprogene <ins class="ins ins-before">php,</ins>Sage og <del class="del">python.</del><ins class="ins ins-after">ruby.</ins>'
      end
    end
  end
end
