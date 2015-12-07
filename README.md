# Markdiff
Rendered Markdown differ.

## Usage
```rb
require "markdiff"

differ = Markdiff::Differ.new
node = differ.render("<p>a</p>", "<p>b</p>")
node.to_html #=> "<p><del>a</del><ins>b</ins></p>"
```
