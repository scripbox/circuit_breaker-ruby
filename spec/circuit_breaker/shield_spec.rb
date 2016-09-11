require 'spec_helper'
require 'circuit_breaker-ruby/shield'

describe CircuitBreaker::Shield do
  let(:circuit_breaker_shield) do
    CircuitBreaker::Shield.new(invocation_timeout: 1, retry_timeout: 1, failure_threshold: 1)
  end

  it 'goes to closed state' do
    circuit_breaker_shield.call { sleep(0.1) }

    expect(circuit_breaker_shield.send :state).to be(CircuitBreaker::Shield::States::CLOSED)
  end

  it 'goes to open state' do
    no_of_tries = circuit_breaker_shield.failure_threshold * 2
    no_of_failures = no_of_tries * CircuitBreaker::Shield::FAILURE_THRESHOLD_PERCENTAGE
    no_of_success = no_of_tries - no_of_failures
    no_of_success.to_i.times { circuit_breaker_shield.call { sleep(0.1) } }
    no_of_failures.to_i.times { circuit_breaker_shield.call { sleep(2) } }

    expect(circuit_breaker_shield.send :state).to be(CircuitBreaker::Shield::States::OPEN)
  end

  it 'goes to half open state' do
    no_of_tries = circuit_breaker_shield.failure_threshold * 2
    no_of_failures = no_of_tries * CircuitBreaker::Shield::FAILURE_THRESHOLD_PERCENTAGE
    no_of_success = no_of_tries - no_of_failures
    no_of_success.to_i.times { circuit_breaker_shield.call { sleep(0.1) } }
    no_of_failures.to_i.times { circuit_breaker_shield.call { sleep(2) } }
    sleep(1)

    expect(circuit_breaker_shield.send :state).to be(CircuitBreaker::Shield::States::HALF_OPEN)
  end

  it 'raises CircuitBreaker::Shield::Open' do
     no_of_tries = circuit_breaker_shield.failure_threshold * 2
    no_of_failures = no_of_tries * CircuitBreaker::Shield::FAILURE_THRESHOLD_PERCENTAGE
    no_of_success = no_of_tries - no_of_failures
    no_of_success.to_i.times { circuit_breaker_shield.call { sleep(0.1) } }

    expect { (no_of_failures.to_i + 1).times { circuit_breaker_shield.call { sleep(2) } } }.to(
      raise_error(CircuitBreaker::Open)
    )
  end
end
