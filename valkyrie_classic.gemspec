# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'valkyrie_classic/version'

Gem::Specification.new do |spec|
  spec.name          = "valkyrie_classic"
  spec.version       = Valkyrie::Classic::VERSION
  spec.authors       = ["Ben Armintor"]
  spec.email         = ["armintor@gmail.com"]

  spec.summary       = 'Valkyrie adapters wrapping Rubydora and Rsolr'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency 'valkyrie'
  spec.add_dependency 'rubydora'
  spec.add_dependency 'rsolr'
  spec.add_dependency 'rdf'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'jettywrapper', '>= 1.5.1'
  spec.add_development_dependency 'bixby'
end
