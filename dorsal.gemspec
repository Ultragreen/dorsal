# frozen_string_literal: true

require_relative "lib/dorsal/version"

Gem::Specification.new do |spec|
  spec.name          = "dorsal"
  spec.version       = `cat VERSION`.chomp
  spec.authors       = ['Romain GEORGES']
  spec.email         = ['romain@ultragreen.net']
  spec.license = 'MIT'

  spec.summary       = "Dorsal : Distribution Of Ruby Services on line"
  spec.description   = "Dorsal 2 is a complete rewrite for Carioca 2."
  spec.homepage      = "https://github.com/Ultragreen/dorsal"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
  
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency 'code_statistics', '~> 0.2.13'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.32'
  spec.add_development_dependency 'yard', '~> 0.9.27'
  spec.add_development_dependency 'yard-rspec', '~> 0.1'
  spec.add_development_dependency "bundle-audit", "~> 0.1.0"

  spec.add_dependency "stringio", "~> 3.0"
  spec.add_dependency "rest-client", "~> 2.1"
  spec.add_dependency "sinatra", "~> 3.0"
  spec.add_dependency "carioca", "~> 2.1"
  spec.add_dependency "thor", "~> 1.2"


end
