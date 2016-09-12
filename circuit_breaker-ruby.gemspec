require './lib/circuit_breaker-ruby/version'

Gem::Specification.new do |gem|
  gem.name         = 'circuit_breaker-ruby'
  gem.version      = CircuitBreaker::VERSION
  gem.date         = '2016-09-09'
  gem.summary      = 'Circuit breaker for ruby'
  gem.description  = 'Self-resetting breaker retries the protected call after a suitable interval, and it also resets when the call succeeds.'
  gem.author       = 'Scripbox'
  gem.email        = 'tech@sripbox.com'
  gem.homepage     = 'https://github.com/scripbox/circuit_breaker-ruby'
  gem.license      = 'MIT'

  gem.require_path = 'lib'
  gem.files        = `git ls-files`.split($/)
  gem.test_files   = Dir.glob('spec/**/*')

  gem.required_ruby_version = '>= 2.1.8'

  gem.add_dependency 'rspec', '>= 3'
  gem.add_dependency 'rake', '>= 10'
end
