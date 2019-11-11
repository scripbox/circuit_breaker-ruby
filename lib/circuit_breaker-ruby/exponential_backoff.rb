module CircuitBreaker
  module ExponentialBackoff
    def self.calc_next_backoff(count, backoff_initial, backoff_max, backoff_exponent)
      next_exponential_backoff = ((backoff_initial * count) ** backoff_exponent) + rand(30)

      return next_exponential_backoff.round(2) unless backoff_max

      [next_exponential_backoff, backoff_max].min
    end
  end
end
