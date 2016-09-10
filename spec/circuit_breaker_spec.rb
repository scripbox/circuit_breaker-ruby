require 'spec_helper'
require 'circuit_breaker'

describe CircuitBreaker do
  let(:circuit_breaker_instance) do
    CircuitBreaker.new(invocation_timeout: 1, retry_timeout: 1, failure_threshold: 1)
  end

  it 'goes to closed state' do
    circuit_breaker_instance.call { sleep(0.1) }

    expect(circuit_breaker_instance.send :state).to be(CircuitBreaker::States::CLOSED)
  end

  it 'goes to open state' do
    no_of_tries = circuit_breaker_instance.failure_threshold * 2
    no_of_failures = no_of_tries * CircuitBreaker::FAILURE_THRESHOLD_PERCENTAGE
    no_of_success = no_of_tries - no_of_failures
    no_of_success.to_i.times { circuit_breaker_instance.call { sleep(0.1) } }
    no_of_failures.to_i.times { circuit_breaker_instance.call { sleep(2) } }

    expect(circuit_breaker_instance.send :state).to be(CircuitBreaker::States::OPEN)
  end

  it 'goes to half open state' do
    no_of_tries = circuit_breaker_instance.failure_threshold * 2
    no_of_failures = no_of_tries * CircuitBreaker::FAILURE_THRESHOLD_PERCENTAGE
    no_of_success = no_of_tries - no_of_failures
    no_of_success.to_i.times { circuit_breaker_instance.call { sleep(0.1) } }
    no_of_failures.to_i.times { circuit_breaker_instance.call { sleep(2) } }
    sleep(1)

    expect(circuit_breaker_instance.send :state).to be(CircuitBreaker::States::HALF_OPEN)
  end

  it 'raises CircuitBreaker::Open' do
     no_of_tries = circuit_breaker_instance.failure_threshold * 2
    no_of_failures = no_of_tries * CircuitBreaker::FAILURE_THRESHOLD_PERCENTAGE
    no_of_success = no_of_tries - no_of_failures
    no_of_success.to_i.times { circuit_breaker_instance.call { sleep(0.1) } }

    expect { (no_of_failures.to_i + 1).times { circuit_breaker_instance.call { sleep(2) } } }.to(
      raise_error(CircuitBreaker::Open)
    )
  end
end
