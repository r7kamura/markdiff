# Markdiff
Rendered Markdown differ.

## Usage
```rb
require "markdiff"

differ = Markdiff::Differ.new
node = differ.render("<p>a</p>", "<p>b</p>")
node.to_html #=> "<p><del>a</del><ins>b</ins></p>"
```

See [spec/markdiff/differ_spec.rb](spec/markdiff/differ_spec.rb) for more examples.
