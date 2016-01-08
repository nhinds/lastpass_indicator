# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lastpass_indicator/version'

Gem::Specification.new do |spec|
  spec.name          = 'lastpass_indicator'
  spec.version       = LastPassIndicator::VERSION
  spec.authors       = ['Nicholas Hinds']
  spec.email         = ['hindsn@gmail.com']
  spec.summary       = 'Indicator for inserting passwords from LastPass into linux applications.'
  spec.description   = 'Indicator for inserting passwords from LastPass into linux applications.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'ruby-libappindicator'
  spec.add_dependency 'lastpass'
  spec.add_dependency 'xdg'
  spec.add_dependency 'xdo'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
