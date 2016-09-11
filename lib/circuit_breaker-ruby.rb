require 'circuit_breaker-ruby/version'
require 'circuit_breaker-ruby/shield'
require 'timeout'

module CircuitBreaker
  class Open < StandardError; end
end
