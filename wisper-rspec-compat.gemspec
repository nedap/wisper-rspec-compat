# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wisper/rspec/version'

Gem::Specification.new do |spec|
  spec.name          = "wisper-rspec-compat"
  spec.version       = Wisper::Rspec::VERSION
  spec.authors       = ["Kris Leech", "Jamie Schembri"]
  spec.email         = ["kris.leech@gmail.com", "jamie.schembri@nedap.com"]
  spec.summary       = "Rspec matchers and stubbing for Wisper-Compat"
  spec.description   =  "Rspec matchers and stubbing for Wisper-Compat"
  spec.homepage      = "https://github.com/nedap/wisper-rspec-compat"
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib}/**/*") + %w[LICENSE.txt README.md CHANGELOG.md]
  spec.require_paths = ["lib"]

  spec.required_ruby_version  = '>= 2.7'
end
