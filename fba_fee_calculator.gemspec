# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fba_fee_calculator/version'

Gem::Specification.new do |spec|
  spec.name          = "fba_fee_calculator"
  spec.version       = FbaFeeCalculator::VERSION
  spec.authors       = ["Eric Berry"]
  spec.email         = ["eric@sellerated.com"]

  spec.summary       = %q{Calculates Amazon FBA Fees for Merchants}
  spec.description   = %q{This gem can be used to calculate FBA fees for Amazon merchants. It should return similar values to: https://sellercentral.amazon.com/hz/fba/profitabilitycalculator/index}
  spec.homepage      = "https://www.github.com/sellerated/fba_fee_calculator"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 4.2"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "timecop", "~> 0.8.1"
end
