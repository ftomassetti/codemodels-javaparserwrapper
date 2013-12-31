# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codemodels/javaparserwrapper/version'

Gem::Specification.new do |spec|
  spec.platform      = 'java'
  spec.name          = "codemodels-javaparserwrapper"
  spec.version       = CodeModels::JavaParserWrapper::VERSION
  spec.authors       = ["Federico Tomassetti"]
  spec.email         = ["f.tomassetti@gmail.com"]
  spec.description   = %q{Code to wrap parsers written in Java and produce models suitable to be used in CodeModels}
  spec.summary       = %q{Code to wrap parsers written in Java and produce models suitable to be used in CodeModels}
  spec.homepage      = ""
  spec.license       = "Apache v2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "codemodels"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
end
