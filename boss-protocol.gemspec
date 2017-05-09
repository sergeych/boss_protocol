# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'boss-protocol/version'

Gem::Specification.new do |gem|
  gem.name          = "boss-protocol"
  gem.version       = Boss::VERSION
  gem.authors       = ["sergeych"]
  gem.email         = ["real.sergeych@gmail.com"]
  gem.description   = %q{Binary streamable bit-effective protocol to effectively store object tree hierarchies}
  gem.summary       = %q{Traversable and streamable to protocol supports lists, hashes, caching, datetime, texts,
unlimited integers, floats, compression and more}
  gem.homepage      = "https://github.com/sergeych/boss_protocol"
  gem.licenses      = ["MIT"]

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  #gem.add_dependency 'bzip2-ruby'
  gem.add_development_dependency "rspec", '~> 2.14'
end
