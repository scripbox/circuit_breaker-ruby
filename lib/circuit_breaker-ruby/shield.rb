module CircuitBreaker
  class Shield
    module States
      OPEN = :open
      CLOSED = :closed
      HALF_OPEN = :half_open
    end

    attr_reader :invocation_timeout,
                :retry_timeout,
                :failure_threshold,
                :failure_threshold_percentage,
                :total_count,
                :failure_count,
                :backoff_initial,
                :backoff_max,
                :backoff_count,
                :backoff_exponent

    def initialize(**options)
      @failure_count = 0
      @total_count = 0
      @backoff_exponent = 1.5
      @backoff_initial = options.fetch(:backoff_initial, nil)
      @backoff_max = options.fetch(:backoff_max, nil)
      @backoff_count = 0
      @failure_threshold = options.fetch(:failure_threshold, config.failure_threshold)
      @failure_threshold_percentage = options.fetch(:failure_threshold_percentage, config.failure_threshold_percentage)
      @invocation_timeout = options.fetch(:invocation_timeout, config.invocation_timeout)
      if @backoff_initial.nil?
        @retry_timeout = options.fetch(:retry_timeout, config.retry_timeout)
      else
        @retry_timeout = @backoff_initial
      end
      @callback = options[:callback]
    end

    def config
      CircuitBreaker.config
    end

    def update_config!(options)
      CircuitBreaker::Config.update(self, options)
    end

    def protect(options = {}, &block)
      update_config!(options)

      case prev_state = state
      when States::CLOSED, States::HALF_OPEN
        connect(&block)
      when States::OPEN
        raise CircuitBreaker::Open
      end
    end

    private

    def state
      if reached_failure_threshold? && reached_failure_threshold_percentage? && reached_retry_timeout?
        States::HALF_OPEN
      elsif reached_failure_threshold? && reached_failure_threshold_percentage?
        set_new_retry_timeout
        States::OPEN
      else
        States::CLOSED
      end
    end

    def set_new_retry_timeout
      return if @backoff_initial.nil?

      @backoff_count += 1
      @retry_timeout = ExponentialBackoff.calc_next_backoff(@backoff_count, @backoff_initial, @backoff_max, @backoff_exponent)
    end

    def reached_failure_threshold?
      (failure_count >= failure_threshold)
    end

    def reached_failure_threshold_percentage?
      (total_count.nonzero? && (failure_count.to_f / total_count.to_f) >= failure_threshold_percentage)
    end

    def reached_retry_timeout?
      (Time.now - @last_failure_time) > @retry_timeout
    end

    def reset
      @failure_count = 0
      @total_count = 0
      @backoff_count = 0
      @state = States::CLOSED
    end

    def connect(&block)
      begin
        result = nil
        ::Timeout::timeout(invocation_timeout) do
          start_time = Time.now
          result = block.call
          duration = Time.now - start_time
          invoke_callback(result, duration: duration)
          reset
        end
      rescue ::Timeout::Error => e
        record_failure
        invoke_callback
        raise CircuitBreaker::TimeoutError
      ensure
        increment_total_count
      end

      result
    end

    def increment_total_count
      @total_count += 1
    end

    def record_failure
      @last_failure_time = Time.now
      @failure_count += 1
    end

    def invoke_callback(result = nil, options = {})
      @callback.respond_to?(:call) && @callback.call(result, options)
    end
  end
end
