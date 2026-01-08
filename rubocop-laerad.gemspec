# frozen_string_literal: true

require_relative "lib/rubocop/laerad/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-laerad"
  spec.version = RuboCop::Laerad::VERSION
  spec.authors = ["Giles Bowkett"]
  spec.summary = "RuboCop cop for detecting single-use variables"
  spec.homepage = "https://github.com/gilesbowkett/laerad"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rubocop", ">= 1.0"
end
