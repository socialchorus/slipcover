# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slipcover/version'

Gem::Specification.new do |spec|
  spec.name          = "slipcover"
  spec.version       = Slipcover::VERSION
  spec.authors       = ["Kane Baccigalupi", "Deepti Anand", "Fito von Zastow", 'SocialCoders @ SocialChorus']
  spec.email         = ["baccigalupi@gmail.com", "developers@socialchorus.com"]
  spec.description   = %q{Lite wrapper for CouchDB}
  spec.summary       = %q{Lite wrapper for CouchDB}
  spec.homepage      = "http://github.com/socialchorus/slipcover"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"
  spec.add_dependency 'activesupport'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
end
