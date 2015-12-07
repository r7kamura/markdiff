lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "markdiff/version"

Gem::Specification.new do |spec|
  spec.name          = "markdiff"
  spec.version       = Markdiff::VERSION
  spec.authors       = ["r7kamura"]
  spec.email         = ["r7kamura@gmail.com"]
  spec.summary       = "Rendered Markdown differ."
  spec.homepage      = "https://github.com/r7kamura/markdiff"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "pry", "0.10.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "3.4.0"
  spec.add_runtime_dependency "nokogiri"
end
