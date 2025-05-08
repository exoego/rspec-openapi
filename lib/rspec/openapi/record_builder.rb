# frozen_string_literal: true

require 'action_dispatch'
require 'rspec/openapi/record'

class << RSpec::OpenAPI::RecordBuilder = Object.new
  # @param [RSpec::ExampleGroups::*] context
  # @param [RSpec::Core::Example] example
  # @return [RSpec::OpenAPI::Record,nil]
  def build(context, example:, extractor:)
    request, response = extractor.request_response(context)
    return if request.nil?

    title = RSpec::OpenAPI.title.then { |t| t.is_a?(Proc) ? t.call(example) : t }
    path, summary, tags, operation_id, required_request_params, raw_path_params, description, security, deprecated, formats =
      extractor.request_attributes(request, example)

    return if RSpec::OpenAPI.ignored_paths.any? { |ignored_path| path.match?(ignored_path) }

    request_headers, response_headers = extract_headers(request, response)

    RSpec::OpenAPI::Record.new(
      title: title,
      http_method: request.method,
      path: path,
      path_params: raw_path_params,
      query_params: request.query_parameters,
      request_params: raw_request_params(request),
      required_request_params: required_request_params,
      request_content_type: request.media_type,
      request_headers: request_headers,
      summary: summary,
      tags: tags,
      formats: formats,
      operation_id: operation_id,
      description: description,
      security: security,
      deprecated: deprecated,
      status: response.status,
      response_body: safe_parse_body(response, response.media_type),
      response_headers: response_headers,
      response_content_type: response.media_type,
      response_content_disposition: response.header['Content-Disposition'],
    ).freeze
  end

  private

  def safe_parse_body(response, media_type)
    # Use raw body, because Nokogiri-parsed HTML are modified (new lines injection, meta injection, and so on) :(
    return response.body if media_type == 'text/html'

    response.parsed_body
  rescue JSON::ParserError
    nil
  end

  def extract_headers(request, response)
    request_headers = RSpec::OpenAPI.request_headers.each_with_object([]) do |header, headers_arr|
      header_key = header.gsub('-', '_').upcase.to_sym

      header_value = request.get_header(['HTTP', header_key].join('_')) ||
                     request.get_header(header_key) ||
                     request.get_header(header_key.to_s)
      headers_arr << [header, header_value] if header_value
    end
    response_headers = RSpec::OpenAPI.response_headers.each_with_object([]) do |header, headers_arr|
      header_key = header
      header_value = response.headers[header_key]
      headers_arr << [header_key, header_value] if header_value
    end
    [request_headers, response_headers]
  end

  # workaround to get real request parameters
  # because ActionController::ParamsWrapper overwrites request_parameters
  def raw_request_params(request)
    original = request.delete_header('action_dispatch.request.request_parameters')
    request.request_parameters
  ensure
    request.set_header('action_dispatch.request.request_parameters', original)
  end
end
