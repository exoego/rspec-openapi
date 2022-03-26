require 'action_dispatch'
require 'rspec/openapi/record'

class << RSpec::OpenAPI::RecordBuilder = Object.new
  # @param [RSpec::ExampleGroups::*] context
  # @param [RSpec::Core::Example] example
  # @return [RSpec::OpenAPI::Record,nil]
  def build(context, example:)
    if rack_test?(context)
      request = ActionDispatch::Request.new(context.last_request.env)
      request.body.rewind if request.body.respond_to?(:rewind)
      response = ActionDispatch::TestResponse.new(*context.last_response.to_a)
    else
      request = context.request
      response = context.response
    end
    return if request.nil?

    # Generate `path` and `summary` in a framework-friendly manner when possible
    if rails?
      route = find_rails_route(request)
      return warn("RSpec::OpenAPI - No route matched for #{request.request_method} #{request.path_info}") unless route

      path = route.path.spec.to_s.delete_suffix('(.:format)')
      summary = route.requirements[:action] || "#{request.method} #{path}"
      tags = [route.requirements[:controller]&.classify].compact
    else
      path = request.path
      summary = "#{request.method} #{request.path}"
    end

    response_body =
      begin
        response.parsed_body
      rescue JSON::ParserError
        nil
      end

    request_headers = RSpec::OpenAPI.request_headers.each_with_object([]) do |header, headers_arr|
      header_key = header.gsub(/-/, '_').upcase
      header_value = request.get_header(['HTTP', header_key].join('_')) || request.get_header(header_key)
      headers_arr << [header, header_value] if header_value
    end

    metadata_options = example.metadata[:openapi] || {}

    RSpec::OpenAPI::Record.new(
      method: request.request_method,
      path: path,
      path_params: raw_path_params(request),
      query_params: request.query_parameters,
      request_params: raw_request_params(request),
      request_content_type: request.media_type,
      request_headers: request_headers,
      summary: metadata_options[:summary] || summary,
      tags: metadata_options[:tags] || tags,
      description: metadata_options[:description] || RSpec::OpenAPI.description_builder.call(example),
      status: response.status,
      response_body: response_body,
      response_content_type: response.media_type,
      response_content_disposition: response.header["Content-Disposition"],
    ).freeze
  end

  private

  def rails?
    defined?(Rails) && Rails.application
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
      result =
        if route.app.matches?(request)
          if route.app.engine?
            find_rails_route(request, app: route.app.app, fix_path: false)
          else
            route
          end
        end

      return result if result
    end

    nil
  end

  # :controller and :action always exist. :format is added when routes is configured as such.
  def raw_path_params(request)
    if rails?
      request.path_parameters.reject do |key, _value|
        %i[controller action format].include?(key)
      end
    else
      request.path_parameters
    end
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
