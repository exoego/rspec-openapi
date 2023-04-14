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

    path, summary, tags, raw_path_params = generate_path_summary_tags(request)

    metadata_options = example.metadata[:openapi] || {}

    request_headers, response_headers = extract_headers(request, response)

    RSpec::OpenAPI::Record.new(
      http_method: request.method,
      path: path,
      path_params: raw_path_params,
      query_params: request.query_parameters,
      request_params: raw_request_params(request),
      request_content_type: request.media_type,
      request_headers: request_headers,
      summary: metadata_options[:summary] || summary,
      tags: metadata_options[:tags] || tags,
      description: metadata_options[:description] || RSpec::OpenAPI.description_builder.call(example),
      security: metadata_options[:security],
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

  def generate_path_summary_tags(request)
    if rails?
      route = find_rails_route(request)
      path = route.path.spec.to_s.delete_suffix('(.:format)')
      summary = route.requirements[:action] || "#{request.method} #{path}"
      tags = [route.requirements[:controller]&.classify].compact
      # :controller and :action always exist. :format is added when routes is configured as such.
      raw_path_params = request.path_parameters.reject do |key, _value|
        %i[controller action format].include?(key)
      end
    else
      path = request.path
      summary = "#{request.method} #{request.path}"
      tags = nil
      raw_path_params = request.path_parameters
    end
    [path, summary, tags, raw_path_params]
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
  def find_rails_route(request, app: Rails.application, fix_path: true)
    # Reverse the destructive modification by Rails https://github.com/rails/rails/blob/v6.0.3.4/actionpack/lib/action_dispatch/journey/router.rb#L33-L41
    if fix_path && !request.script_name.empty?
      request = request.dup
      request.path_info = File.join(request.script_name, request.path_info)
    end

    app.routes.router.recognize(request) do |route|
      if route.app.matches?(request)
        return find_rails_route(request, app: route.app.app, fix_path: false) if route.app.engine?

        return route
      end
    end
    raise "No route matched for #{request.request_method} #{request.path_info}"
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
