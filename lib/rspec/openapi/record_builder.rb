# frozen_string_literal: true

require 'action_dispatch'
require 'rspec/openapi/record'

class << RSpec::OpenAPI::RecordBuilder = Object.new
  # @param [RSpec::ExampleGroups::*] context
  # @param [RSpec::Core::Example] example
  # @return [RSpec::OpenAPI::Record,nil]
  def build(context, example:)
    request, response = extract_request_response(context)
    return if request.nil?

    path, summary, tags, operation_id, required_request_params, raw_path_params, description, security =
      extract_request_attributes(request, example)

    request_headers, response_headers = extract_headers(request, response)

    RSpec::OpenAPI::Record.new(
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
      operation_id: operation_id,
      description: description,
      security: security,
      status: response.status,
      response_body: safe_parse_body(response),
      response_headers: response_headers,
      response_content_type: response.media_type,
      response_content_disposition: response.header['Content-Disposition'],
    ).freeze
  end

  private

  def safe_parse_body(response)
    response.parsed_body
  rescue JSON::ParserError
    nil
  end

  def extract_headers(request, response)
    request_headers = RSpec::OpenAPI.request_headers.each_with_object([]) do |header, headers_arr|
      header_key = header.gsub(/-/, '_').upcase
      header_value = request.get_header(['HTTP', header_key].join('_')) || request.get_header(header_key)
      headers_arr << [header, header_value] if header_value
    end
    response_headers = RSpec::OpenAPI.response_headers.each_with_object([]) do |header, headers_arr|
      header_key = header
      header_value = response.headers[header_key]
      headers_arr << [header_key, header_value] if header_value
    end
    [request_headers, response_headers]
  end

  def extract_request_attributes(request, example)
    metadata = example.metadata[:openapi] || {}
    summary = metadata[:summary]
    tags = metadata[:tags]
    operation_id = metadata[:operation_id]
    required_request_params = metadata[:required_request_params] || []
    security = metadata[:security]
    description = metadata[:description] || RSpec::OpenAPI.description_builder.call(example)
    raw_path_params = request.path_parameters
    path = request.path
    if rails?
      # Reverse the destructive modification by Rails https://github.com/rails/rails/blob/v6.0.3.4/actionpack/lib/action_dispatch/journey/router.rb#L33-L41
      fixed_request = request.dup
      fixed_request.path_info = File.join(request.script_name, request.path_info) if request.script_name.present?

      route, path = find_rails_route(fixed_request)
      raise "No route matched for #{fixed_request.request_method} #{fixed_request.path_info}" if route.nil?

      path = path.delete_suffix('(.:format)')
      summary ||= route.requirements[:action]
      tags ||= [route.requirements[:controller]&.classify].compact
      # :controller and :action always exist. :format is added when routes is configured as such.
      # TODO: Use .except(:controller, :action, :format) when we drop support for Ruby 2.x
      raw_path_params = raw_path_params.slice(*(raw_path_params.keys - %i[controller action format]))
    end
    summary ||= "#{request.method} #{path}"
    [path, summary, tags, operation_id, required_request_params, raw_path_params, description, security]
  end

  def extract_request_response(context)
    if rack_test?(context)
      request = ActionDispatch::Request.new(context.last_request.env)
      request.body.rewind if request.body.respond_to?(:rewind)
      response = ActionDispatch::TestResponse.new(*context.last_response.to_a)
    else
      request = context.request
      response = context.response
    end
    [request, response]
  end

  def rails?
    defined?(Rails) && Rails.respond_to?(:application) && Rails.application
  end

  def rack_test?(context)
    defined?(Rack::Test::Methods) && context.class < Rack::Test::Methods
  end

  # @param [ActionDispatch::Request] request
  def find_rails_route(request, app: Rails.application, path_prefix: '')
    app.routes.router.recognize(request) do |route|
      path = route.path.spec.to_s
      if route.app.matches?(request)
        if route.app.engine?
          route, path = find_rails_route(request, app: route.app.app, path_prefix: path)
          next if route.nil?
        end
        return [route, path_prefix + path]
      end
    end
    nil
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
