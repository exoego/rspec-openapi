# frozen_string_literal: true

# Extractor for rack
class << RSpec::OpenAPI::Extractors::Rack = Object.new
  # @param [ActionDispatch::Request] request
  # @param [RSpec::Core::Example] example
  # @return [Hash]
  def request_attributes(request, example)
    path = request.path
    attrs = SharedExtractor.attributes(example)
    attrs.merge(
      path: path,
      path_params: request.path_parameters,
      summary: attrs[:summary] || "#{request.method} #{path}",
    )
  end

  # @param [RSpec::ExampleGroups::*] context
  def request_response(context)
    request = ActionDispatch::Request.new(context.last_request.env)
    request.body.rewind if request.body.respond_to?(:rewind)
    response = ActionDispatch::TestResponse.new(*context.last_response.to_a)

    [request, response]
  end
end
