require 'rspec/openapi/record'

class << RSpec::OpenAPI::RecordBuilder = Object.new
  # @param [RSpec::Core::Example] example
  # @param [RSpec::ExampleGroups::*] context
  # @return [RSpec::OpenAPI::Record]
  def build(example, context:)
    # TODO: Support Non-Rails frameworks
    route = find_route(context.request)
    path = route.path.spec.to_s.delete_suffix('(.:format)')

    RSpec::OpenAPI::Record.new(
      method: context.request.request_method,
      path: path,
      controller: route.requirements[:controller],
      action: route.requirements[:action],
      description: example.description,
      status: context.response.status,
      body: context.response.parsed_body,
      # TODO: get params
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
