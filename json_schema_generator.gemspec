# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json/schema/generator/version'

Gem::Specification.new do |spec|
  spec.name          = "json_schema_generator"
  spec.version       = JSON::Schema::Generator::VERSION
  spec.authors       = ["glejeune"]
  spec.email         = ["gregoire.lejeune@free.fr"]

  spec.summary       = %q{Ruby library to serialize/deserialize Kafka message}
  spec.description   = %q{Ruby library to serialize/deserialize Kafka message}
  spec.homepage      = "https://flamefy.com"

  spec.files         = Dir[ "lib/**/*", "resources/*.json" ]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
