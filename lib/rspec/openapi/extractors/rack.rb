# frozen_string_literal: true

# Extractor for rack
class << RSpec::OpenAPI::Extractors::Rack = Object.new
  # @param [ActionDispatch::Request] request
  # @param [RSpec::Core::Example] example
  # @return Array
  def request_attributes(request, example)
    summary, tags, formats, operation_id, required_request_params, security, description, deprecated, example_mode,
      example_key, example_name = SharedExtractor.attributes(example)

    raw_path_params = request.path_parameters
    path = request.path
    summary ||= "#{request.method} #{path}"

    [
      path,
      summary,
      tags,
      operation_id,
      required_request_params,
      raw_path_params,
      description,
      security,
      deprecated,
      formats,
      example_mode,
      example_key,
      example_name,
    ]
  end

  # @param [RSpec::ExampleGroups::*] context
  def request_response(context)
    request = ActionDispatch::Request.new(context.last_request.env)
    request.body.rewind if request.body.respond_to?(:rewind)
    response = ActionDispatch::TestResponse.new(*context.last_response.to_a)

    [request, response]
  end
end
