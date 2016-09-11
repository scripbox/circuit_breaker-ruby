## Circuit Breaker
  A circuit breaker which terminates a connection or block of code from executing when it reaches the failure threshold and a percentage. Also it gets reset when a connection succeeds. It also keeps monitoring if connections are working again by checking if it has attained a time to retry.

## Installation

  ```
  gem install circuit_breaker-ruby
  ```

## Usage

  ```
  circuit_breaker = CircuitBreaker::Shield.new(
    invocation_timeout: 1,
    failure_threshold: 2,
    failure_threshold_percentage, 0.2,
    retry_timeout: 10
  )
  ```

### Running the specs

  ```
  bundle exec rspec spec
  ```

### Contributing

If you have any issues with circuit_breaker-ruby,
or feature requests,
please [add an issue](https://github.com/vasuadari/circuit_breaker-ruby/issues) on GitHub
or fork the project and send a pull request.
Please include passing specs with all pull requests.
