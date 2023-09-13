# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "tracer"
  spec.version       = "0.1"
  spec.authors       = ["Twitch"]
  spec.email         = ["webcorps@twitch.tv"]
  spec.description   = %q{Rails Tracer}
  spec.summary       = %q{Traces Rails and ActiveRecord}
  spec.homepage      = "http://twitch.tv"
  spec.licenses      = ["None"]

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
