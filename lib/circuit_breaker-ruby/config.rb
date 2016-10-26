module CircuitBreaker
  class Config
    FAILURE_THRESHOLD = 10
    FAILURE_THRESHOLD_PERCENTAGE = 0.5
    INVOCATION_TIMEOUT = 10
    RETRY_TIMEOUT = 60

    UPDATABLE = [
      :invocation_timeout,
      :failure_threshold,
      :failure_threshold_percentage,
      :retry_timeout
    ]

    attr_accessor :invocation_timeout, :failure_threshold, :failure_threshold_percentage, :retry_timeout

    def initialize
      self.failure_threshold = FAILURE_THRESHOLD
      self.failure_threshold_percentage = FAILURE_THRESHOLD_PERCENTAGE
      self.invocation_timeout = INVOCATION_TIMEOUT
      self.retry_timeout = RETRY_TIMEOUT
    end
  end
end
