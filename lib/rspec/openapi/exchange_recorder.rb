# frozen_string_literal: true

module RSpec::OpenAPI::ExchangeRecorder
  THREAD_KEY = :rspec_openapi_exchanges
  VERBS = [:get, :post, :put, :patch, :delete, :head, :options].freeze

  module VerbTracking
    VERBS.each do |verb|
      define_method(verb) do |*args, &block|
        result = super(*args, &block)
        RSpec::OpenAPI::ExchangeRecorder.capture_from_context(self)
        result
      end
      ruby2_keywords(verb)
    end
  end

  class << self
    def reset!(example)
      if pattern_for(example)
        example.example_group.prepend(VerbTracking)
        Thread.current[THREAD_KEY] = []
      else
        Thread.current[THREAD_KEY] = nil
      end
    end

    def pattern_for(example)
      SharedExtractor.merge_openapi_metadata(example.metadata)[:request_pattern]
    end

    def capture_from_context(context)
      exchanges = Thread.current[THREAD_KEY]
      return unless exchanges

      exchanges << build_exchange(context)
    end

    # Returns the exchange matching a `"METHOD /path/template"` pattern.
    #
    # @param [String] pattern e.g. "DELETE /resources/{id}"
    # @return [Array(ActionDispatch::Request, ActionDispatch::TestResponse)]
    def fetch(pattern)
      method, path_template = parse_pattern(pattern)
      path_matcher = path_template_to_regexp(path_template)

      found = recorded.reverse_each.find do |request, _response|
        request.request_method.to_s.upcase == method && request.path.match?(path_matcher)
      end
      return found if found

      raise ArgumentError, no_match_message(pattern)
    end

    private

    def recorded
      Thread.current[THREAD_KEY]
    end

    def parse_pattern(pattern)
      match = %r{\A(\S+)\s+(/\S*)\z}.match(pattern.to_s.strip)
      unless match
        raise ArgumentError,
              "[rspec-openapi] Invalid request_pattern #{pattern.inspect}. " \
              'Expected "<HTTP method> <path>", e.g. "DELETE /widgets/{id}".'
      end

      [match[1].upcase, match[2]]
    end

    def no_match_message(pattern)
      issued = recorded.map { |request, _response| "#{request.request_method} #{request.path}" }
      listing = issued.empty? ? '(no requests were recorded)' : issued.join(', ')
      "[rspec-openapi] request_pattern #{pattern.inspect} did not match any request " \
        "issued in this example. Recorded requests: #{listing}."
    end

    def path_template_to_regexp(template)
      segments = template.split(/\{[^}]+\}/, -1)
      pattern = segments.map { |segment| Regexp.escape(segment) }.join('[^/]+')
      /\A#{pattern}\z/
    end

    def build_exchange(context)
      if context.respond_to?(:last_request)
        SharedExtractor.build_request_response(context.last_request.env, context.last_response.to_a)
      else
        session = context.instance_variable_get(:@integration_session)
        SharedExtractor.build_request_response(session.request.env, session.response.to_a)
      end
    end
  end
end
