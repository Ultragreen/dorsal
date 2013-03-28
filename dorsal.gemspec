# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dorsal/version'

Gem::Specification.new do |spec|
  spec.name          = "dorsal"
  spec.version       = Dorsal::VERSION
  spec.authors       = ["Romain GEORGES"]
  spec.email         = ["romain@ultragreen.net"]
  spec.description   = %q{Dorsal : Druby Objects's Ring Server as an simple Alternative to Linda}
  spec.summary       = %q{Dorsal provide a simple and easy to use Ring Server for DRuby Objects based services architectures}
  spec.homepage      = "http://www.ultragreen.net/projects/dorsal"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_development_dependency('methodic', '>= 1.2')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('yard')
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('roodi')
  spec.add_development_dependency('code_statistics')
  spec.add_development_dependency('yard-rspec')
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_dependency "daemons"

  spec.required_ruby_version = '>= 1.8.1'
  spec.rubyforge_project = "nowarning"
  spec.has_rdoc = true
end
