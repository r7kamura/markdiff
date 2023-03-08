lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "markdiff/version"

Gem::Specification.new do |spec|
  spec.name          = "markdiff"
  spec.version       = Markdiff::VERSION
  spec.authors       = ["Ryo Nakamura"]
  spec.email         = ["r7kamura@gmail.com"]
  spec.summary       = "Rendered Markdown differ."
  spec.homepage      = "https://github.com/r7kamura/markdiff"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.start_with?("spec/") }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "rspec"
  spec.add_runtime_dependency "diff-lcs"
  spec.add_runtime_dependency "nokogiri"
end
