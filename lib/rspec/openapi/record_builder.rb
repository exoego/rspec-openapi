require 'rspec/openapi/record'

class << RSpec::OpenAPI::RecordBuilder = Object.new
  # @param [RSpec::Core::Example] example
  # @param [RSpec::ExampleGroups::*] context
  # @return [RSpec::OpenAPI::Record]
  def build(example, context:)
    RSpec::OpenAPI::Record.new(
      method: context.request.request_method,
      path: context.request.path_info, # TODO: get Rails route
      description: example.description,
      status: context.response.status,
      body: context.response.parsed_body,
      # TODO: get params
    ).freeze
  end
end
