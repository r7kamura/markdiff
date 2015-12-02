# Markdiff
Rendered Markdown differ.

## Usage
### Code
```rb
Markdiff::Differ.new.render(
  "<p>a</p>",
  "<p>b</p>"
).to_html
```

### Output
Note: slightly modified for displaying

```
<del><p>a</p></del>
<ins><p>b</p></ins>
```
