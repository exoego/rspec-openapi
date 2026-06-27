# frozen_string_literal: true

module RSpec::OpenAPI::RequestRecorder
  THREAD_KEY = :rspec_openapi_first_exchange
  VERBS = %i[get post put patch delete head options].freeze

  module RackMethodsTracking
    VERBS.each do |verb|
      define_method(verb) do |*args, **kwargs, &block|
        result = super(*args, **kwargs, &block)
        RSpec::OpenAPI::RequestRecorder.capture_from_context(self)
        result
      end
    end
  end

  module RailsRunnerTracking
    VERBS.each do |verb|
      define_method(verb) do |*args, **kwargs, &block|
        result = super(*args, **kwargs, &block)
        RSpec::OpenAPI::RequestRecorder.capture_from_context(self)
        result
      end
    end
  end

  class << self
    def install!
      return if @installed

      prepend_tracking_module(::Rack::Test::Methods, RackMethodsTracking) if defined?(::Rack::Test::Methods)
      prepend_tracking_module(::ActionDispatch::Integration::Runner, RailsRunnerTracking) if defined?(::ActionDispatch::Integration::Runner)

      @installed = true
    end

    def reset!
      Thread.current[THREAD_KEY] = nil
    end

    def first_exchange
      Thread.current[THREAD_KEY]
    end

    def capture_from_context(context)
      return if first_exchange

      request, response = build_exchange(context)
      return unless request && response

      Thread.current[THREAD_KEY] = [request, response]
    end

    private

    def prepend_tracking_module(target, mod)
      return unless target.is_a?(Module)
      return if target.ancestors.include?(mod)

      target.prepend(mod)
    end

    def build_exchange(context)
      if context.respond_to?(:last_request) && context.respond_to?(:last_response)
        last_request = context.last_request
        last_response = context.last_response
        if last_request && last_response
          request = ActionDispatch::Request.new(last_request.env)
          request.body.rewind if request.body.respond_to?(:rewind)
          response = ActionDispatch::TestResponse.new(*last_response.to_a)
          return [request, response]
        end
      end

      session = context.instance_variable_get(:@integration_session)
      return [session.request, session.response] if session&.request && session&.response

      [nil, nil]
    end
  end
end
