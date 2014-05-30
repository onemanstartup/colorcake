# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'colorcake/version'

Gem::Specification.new do |spec|
  spec.name          = 'colorcake'
  spec.version       = Colorcake::VERSION
  spec.authors       = ['Plehanov Dmitriy']
  spec.email         = ['onemanstartup@gmail.com']
  spec.description   = %q{Cake description}
  spec.summary       = %q{Summer summary}
  spec.homepage      = ""
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'method_profiler'
  spec.add_development_dependency "ruby-prof"
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'

  spec.add_dependency 'rmagick'
end
