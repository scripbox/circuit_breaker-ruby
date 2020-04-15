## Circuit Breaker
[![Gem Version](https://img.shields.io/gem/v/circuit_breaker-ruby.svg?style=flat)](http://rubygems.org/gems/circuit_breaker-ruby)
[![Gem Downloads](https://img.shields.io/gem/dt/circuit_breaker-ruby.svg?style=flat)](http://rubygems.org/gems/circuit_breaker-ruby)
![build](https://github.com/scripbox/circuit_breaker-ruby/workflows/build/badge.svg)

  A circuit breaker which terminates the connection or block of code from executing when it reaches the timeout. It helps in preventing blocking requests from slowing down your server.

## How it works

Refer the following diagram:

![CircuitBreaker](https://raw.githubusercontent.com/scripbox/circuit_breaker-ruby/master/circuit_breaker.png)

## Getting started

  Add following line to your Gemfile:
  ```ruby
  gem 'circuit_breaker-ruby', '~> 0.1.3'
  ```

## Usage

  ```ruby
  circuit_breaker = CircuitBreaker::Shield.new(
    invocation_timeout: 1,
    failure_threshold: 2,
    failure_threshold_percentage: 0.2,
    retry_timeout: 10
  )
  circuit_breaker.protect { sleep(10) }
  ```

## Running tests

  ```ruby
  bundle exec rake
  ```

## Configuration

Add the following configuration to `config/initializers/circuit_breaker.rb`. These are the default values.

  ```ruby
  CircuitBreaker.configure do |cb|
    cb.failure_threshold = 10
    cb.failure_threshold_percentage = 0.5
    cb.invocation_timeout = 10
    cb.retry_timeout = 60
  end
  ```

## Contributing

If you have any issues with circuit_breaker-ruby,
or feature requests,
please [add an issue](https://github.com/scripbox/circuit_breaker-ruby/issues) on GitHub
or fork the project and send a pull request.
Please include passing specs with all pull requests.

## Copyright and License

Copyright (c) 2019, Scripbox.

circuit_breaker-ruby source code is licensed under the [MIT License](MIT-LICENSE).

## References

[CircuitBreaker](https://martinfowler.com/bliki/CircuitBreaker.html) - [Martin Fowler](https://en.wikipedia.org/wiki/Martin_Fowler_(software_engineer))
