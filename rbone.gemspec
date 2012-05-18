# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rbone/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Mayers"]
  gem.email         = ["matt@mattmayers.com"]
  gem.description   = %q{This gem provides a simple interface for writing Arduino-style programs for the BeagleBone.}
  gem.summary       = %q{Write simple Arduino-style programs for your BeagleBone}
  gem.homepage      = "http://github.com/majormajors/rbone"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rbone"
  gem.require_paths = ["lib"]
  gem.version       = Rbone::VERSION

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "fakefs"
end
