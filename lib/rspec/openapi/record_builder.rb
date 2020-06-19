require 'rspec/openapi/record'

class << RSpec::OpenAPI::RecordBuilder = Object.new
  # @param [RSpec::ExampleGroups::*] context
  # @param [RSpec::Core::Example] example
  # @return [RSpec::OpenAPI::Record]
  def build(context, example:)
    # TODO: Support Non-Rails frameworks
    request = context.request
    response = context.response
    route = find_route(request)

    RSpec::OpenAPI::Record.new(
      method: request.request_method,
      path: route.path.spec.to_s.delete_suffix('(.:format)'),
      path_params: request.path_parameters,
      query_params: request.query_parameters,
      request_params: request.request_parameters,
      request_content_type: request.content_type,
      controller: route.requirements[:controller],
      action: route.requirements[:action],
      description: example.description,
      status: response.status,
      response_body: response.parsed_body,
      response_content_type: response.content_type,
    ).freeze
  end

  private

  # @param [ActionDispatch::Request] request
  def find_route(request)
    Rails.application.routes.router.recognize(request) do |route|
      return route
    end
    raise "No route matched for #{request.request_method} #{request.path_info}"
  end
end
