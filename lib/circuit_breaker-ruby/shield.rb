module CircuitBreaker
  class Shield
    module States
      OPEN = :open
      CLOSED = :closed
      HALF_OPEN = :half_open
    end

    attr_reader :invocation_timeout, :retry_timeout, :failure_threshold, :failure_threshold_percentage,
                :total_count, :failure_count

    def initialize(**options)
      @failure_count = 0
      @total_count = 0
      @failure_threshold = options[:failure_threshold] || config.failure_threshold
      @failure_threshold_percentage = options[:failure_threshold_percentage] || config.failure_threshold_percentage
      @invocation_timeout = options[:invocation_timeout] || config.invocation_timeout
      @retry_timeout = options[:retry_timeout] || config.retry_timeout
      @callback = options[:callback]
    end

    def config
      CircuitBreaker.config
    end

    def update_config!(options)
      (CircuitBreaker::Config::UPDATABLE & options.keys).each do |variable|
        instance_variable_set("@#{variable}", options[variable])
      end
    end

    def protect(options = {}, &block)
      update_config!(options)

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
          start_time = Time.now
          result = block.call
          duration = Time.now - start_time
          @callback.respond_to?(:call) &&
            invoke_callback({ duration: duration }.merge(result || {}))
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

    def invoke_callback(options)
      @callback.call(options)
    end
  end
end
