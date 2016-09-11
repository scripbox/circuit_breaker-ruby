module CircuitBreaker
  class Shield
    FAILURE_THRESHOLD = 10
    FAILURE_THRESHOLD_PERCENTAGE = 0.5
    INVOCATION_TIMEOUT = 10
    RETRY_TIMEOUT = 60

    module States
      OPEN = :open
      CLOSED = :closed
      HALF_OPEN = :half_open
    end

    attr_reader :invocation_timeout, :failure_threshold, :failure_threshold_percentage, :total_count, :failure_count

    def initialize(**options)
      @failure_count = 0
      @total_count = 0
      @failure_threshold = options[:failure_threshold] || FAILURE_THRESHOLD
      @failure_threshold_percentage = options[:failure_threshold_percentage] || FAILURE_THRESHOLD_PERCENTAGE
      @invocation_timeout = options[:invocation_timeout] || INVOCATION_TIMEOUT
      @retry_timeout = options[:retry_timeout] || RETRY_TIMEOUT
    end

    def call(&block)
      case prev_state = state
      when States::CLOSED, States::HALF_OPEN
        connect(&block).tap { update_total_count(prev_state) }
      when States::OPEN
        raise CircuitBreaker::Open
      end
    end

    private

    def state
      case
      when reached_failure_threshold? && reached_retry_timeout?
        States::HALF_OPEN
      when reached_failure_threshold?
        States::OPEN
      else
        States::CLOSED
      end
    end

    def reached_failure_threshold?
      (failure_count >= failure_threshold) &&
        (total_count != 0 &&
          (failure_count.to_f / total_count.to_f) >= failure_threshold_percentage)
    end

    def reached_retry_timeout?
      (Time.now - @last_failure_time) > @retry_timeout
    end

    def reset
      @failure_count = 0
      @state = States::CLOSED
    end

    def connect(&block)
      begin
        result = nil
        Timeout::timeout(invocation_timeout) do
          result = block.call
          reset
        end
      rescue Timeout::Error => e
        record_failure
      end

      result
    end

    def update_total_count(state)
      if state == States::HALF_OPEN
        @total_count = 0
      else
        @total_count += 1
      end
    end

    def record_failure
      @last_failure_time = Time.now
      @failure_count += 1
    end
  end
end
