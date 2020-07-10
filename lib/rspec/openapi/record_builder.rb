require 'action_dispatch'
require 'rspec/openapi/record'

class << RSpec::OpenAPI::RecordBuilder = Object.new
  # @param [RSpec::ExampleGroups::*] context
  # @param [RSpec::Core::Example] example
  # @return [RSpec::OpenAPI::Record,nil]
  def build(context, example:)
    if rack_test?(context)
      request = ActionDispatch::Request.new(context.last_request.env)
      response = ActionDispatch::TestResponse.new(*context.last_response.to_a)
    else
      request = context.request
      response = context.response
    end

    # Generate `path` and `summary` in a framework-friendly manner when possible
    if defined?(Rails) && Rails.application
      route = find_rails_route(request)
      path = route.path.spec.to_s.delete_suffix('(.:format)')
      summary = "#{route.requirements[:controller]} ##{route.requirements[:action]}"
    else
      path = request.path
      summary = "#{request.method} #{request.path}"
    end

    RSpec::OpenAPI::Record.new(
      method: request.request_method,
      path: path,
      path_params: request.path_parameters,
      query_params: request.query_parameters,
      request_params: raw_request_params(request),
      request_content_type: request.content_type,
      summary: summary,
      description: example.description,
      status: response.status,
      response_body: response.parsed_body,
      response_content_type: response.content_type,
    ).freeze
  end

  private

  def rack_test?(context)
    defined?(Rack::Test::Methods) && context.class < Rack::Test::Methods
  end

  # @param [ActionDispatch::Request] request
  def find_rails_route(request)
    Rails.application.routes.router.recognize(request) do |route|
      return route
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
