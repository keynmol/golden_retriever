# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'golden_retriever/version'

Gem::Specification.new do |gem|
  gem.name          = "golden_retriever"
  gem.version       = GoldenRetriever::VERSION
  gem.authors       = ["Anton Sviridov"]
  gem.email         = ["aasviridov@undev.ru"]
  gem.description   = %q{A Mongoid based library for various Information Retrieval tasks}
  gem.summary       = %q{Bla=bla}
  gem.homepage      = ""

  gem.add_development_dependency "rspec"

  gem.add_dependency('mongoid', '~>3.1.4')
  gem.add_dependency('activesupport')
  gem.add_dependency('unicode_utils')
  gem.add_dependency('ruby-stemmer')

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
