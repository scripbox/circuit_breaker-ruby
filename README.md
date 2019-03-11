## Circuit Breaker
[![Gem Version](https://img.shields.io/gem/v/circuit_breaker-ruby.svg?style=flat)](http://rubygems.org/gems/circuit_breaker-ruby)
[![Build Status](https://travis-ci.org/scripbox/circuit_breaker-ruby.svg?style=flat&branch=master)](https://travis-ci.org/scripbox/circuit_breaker-ruby)

  A circuit breaker which terminates a connection or block of code from executing when it reaches the failure threshold and a percentage. Also it gets reset when a connection succeeds. It also keeps monitoring if connections are working again by checking if it has attained a time to retry.

## Installation

  ```ruby
  gem install circuit_breaker-ruby
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

## Running the specs

  ```ruby
  bundle exec rspec spec
  ```

## Configuration

Add the following configuration to config/initializers/circuit_breaker.rb. These are the default values.

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
