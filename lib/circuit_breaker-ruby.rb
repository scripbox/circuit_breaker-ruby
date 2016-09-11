require 'circuit_breaker-ruby/version'
require 'circuit_breaker-ruby/config'
require 'circuit_breaker-ruby/shield'
require 'timeout'

module CircuitBreaker
  class Open < StandardError; end

  class << self
    def config
      @config ||= CircuitBreaker::Config.new
    end

    def configure
      yield @config = CircuitBreaker::Config.new
    end
  end
end
