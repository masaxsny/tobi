# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tobi/version'

Gem::Specification.new do |gem|
  gem.name          = "tobi"
  gem.version       = Tobi::VERSION
  gem.authors       = ["masaxsny"]
  gem.email         = ["masaxsny@gmail.com"]
  gem.description   = %q{Simple sinatra application generator.}
  gem.summary       = %q{Simple sinatra application generator.}
  gem.homepage      = "https://github.com/masaxsny/tobi"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec", "~> 2.11.0"
  gem.add_development_dependency "guard", "~> 1.4.0"
  gem.add_development_dependency "guard-rspec", "~> 2.0.0"
  gem.add_development_dependency "rb-fsevent", "~> 0.9.2"
  # gem.add_runtime_dependency "***"
end
