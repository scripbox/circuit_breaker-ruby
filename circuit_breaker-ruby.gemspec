lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'circuit_breaker-ruby'

Gem::Specification.new do |gem|
  gem.name         = 'circuit_breaker-ruby'
  gem.version      = CircuitBreaker::VERSION
  gem.date         = '2016-10-09'
  gem.summary      = 'Circuit breaker for ruby'
  gem.description  = 'Self-resetting breaker retries the protected call after a suitable interval, and it also resets when the call succeeds.'
  gem.authors      = ['Vasu Adari']
  gem.email        = 'vasuakeel@gmail.com'
  gem.homepage     = 'https://github.com/vasuadari/circuit_breaker-ruby'

  gem.files        = `git ls-files`.split($/)
  gem.require_path = 'lib'

  gem.license      = 'MIT'

  gem.required_ruby_version = '>= 2.1.8'
end
