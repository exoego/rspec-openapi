# frozen_string_literal: true

# Extractor for rack
class << RSpec::OpenAPI::Extractors::Rack = Object.new
  # @param [ActionDispatch::Request] request
  # @param [RSpec::Core::Example] example
  # @return Array
  def request_attributes(request, example)
    metadata = merge_openapi_metadata(example.metadata)
    summary = metadata[:summary] || RSpec::OpenAPI.summary_builder.call(example)
    tags = metadata[:tags] || RSpec::OpenAPI.tags_builder.call(example)
    formats = metadata[:formats] || RSpec::OpenAPI.formats_builder.curry.call(example)
    operation_id = metadata[:operation_id]
    required_request_params = metadata[:required_request_params] || []
    security = metadata[:security]
    description = metadata[:description] || RSpec::OpenAPI.description_builder.call(example)
    deprecated = metadata[:deprecated]
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
    ]
  end

  # @param [RSpec::ExampleGroups::*] context
  def request_response(context)
    request = ActionDispatch::Request.new(context.last_request.env)
    request.body.rewind if request.body.respond_to?(:rewind)
    response = ActionDispatch::TestResponse.new(*context.last_response.to_a)

    [request, response]
  end

  private

  def merge_openapi_metadata(metadata)
    collect_openapi_metadata(metadata).reduce({}, &:merge)
  end

  def collect_openapi_metadata(metadata)
    [].tap do |result|
      current = metadata

      while current
        [current[:example_group], current].each do |meta|
          result.unshift(meta[:openapi]) if meta&.dig(:openapi)
        end

        current = current[:parent_example_group]
      end
    end
  end
end
