# Markdiff [![Build Status](https://travis-ci.org/r7kamura/markdiff.svg)](https://travis-ci.org/r7kamura/markdiff)
Rendered Markdown differ.

## Usage
```rb
require "markdiff"

differ = Markdiff::Differ.new
node = differ.render("<p>a</p>", "<p>b</p>")
node.to_html #=> '<div class="changed"><p><del>a</del><ins>b</ins></p></div>'
```

See [spec/markdiff/differ_spec.rb](spec/markdiff/differ_spec.rb) for more examples.
