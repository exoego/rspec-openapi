# frozen_string_literal: true

require 'dry/inflector'
require 'hanami'

# https://github.com/hanami/router/blob/97f75b8529574bd4ff23165460e82a6587bc323c/lib/hanami/router/inspector.rb#L13
class Inspector
  attr_accessor :routes, :inflector

  def initialize(routes: [])
    @routes = routes
    @inflector = Dry::Inflector.new
  end

  def add_route(route)
    routes.push(route)
  end

  def call(verb, path)
    route = routes.find { |r| r.http_method == verb && r.path == path }

    if route.to.is_a?(Proc)
      {
        tags: [],
        summary: "#{verb} #{path}",
      }
    else
      data = route.to.split('.')

      {
        tags: [inflector.classify(data[0])],
        summary: data[1],
      }
    end
  end
end

InspectorAnalyzer = Inspector.new

# Add default parameter to load inspector before test cases run
module InspectorAnalyzerPrepender
  def router(inspector: InspectorAnalyzer)
    super
  end
end

Hanami::Slice::ClassMethods.prepend(InspectorAnalyzerPrepender)

# Extractor for hanami
class << RSpec::OpenAPI::Extractors::Hanami = Object.new
  # @param [ActionDispatch::Request] request
  # @param [RSpec::Core::Example] example
  # @return Array
  def request_attributes(request, example)
    route = Hanami.app.router.recognize(Rack::MockRequest.env_for(request.path, method: request.method))

    return RSpec::OpenAPI::Extractors::Rack.request_attributes(request, example) unless route.routable?

    metadata = example.metadata[:openapi] || {}
    summary = metadata[:summary] || RSpec::OpenAPI.summary_builder.call(example)
    tags = metadata[:tags] || RSpec::OpenAPI.tags_builder.call(example)
    operation_id = metadata[:operation_id]
    required_request_params = metadata[:required_request_params] || []
    optional_headers = metadata[:optional_headers] || []
    security = metadata[:security]
    description = metadata[:description] || RSpec::OpenAPI.description_builder.call(example)
    deprecated = metadata[:deprecated]
    path = request.path

    raw_path_params = route.params

    result = InspectorAnalyzer.call(request.method, add_id(path, route))

    summary ||= result[:summary]
    tags ||= result[:tags]
    path = add_openapi_id(path, route)

    raw_path_params = raw_path_params.slice(*(raw_path_params.keys - RSpec::OpenAPI.ignored_path_params))

    [path, summary, tags, operation_id, required_request_params, optional_headers, raw_path_params, description, security, deprecated]
  end

  # @param [RSpec::ExampleGroups::*] context
  def request_response(context)
    request = ActionDispatch::Request.new(context.last_request.env)
    request.body.rewind if request.body.respond_to?(:rewind)
    response = ActionDispatch::TestResponse.new(*context.last_response.to_a)

    [request, response]
  end

  def add_id(path, route)
    return path if route.params.empty?

    route.params.each_pair do |key, value|
      path = path.sub("/#{value}", "/:#{key}")
    end

    path
  end

  def add_openapi_id(path, route)
    return path if route.params.empty?

    route.params.each_pair do |key, value|
      path = path.sub("/#{value}", "/{#{key}}")
    end

    path
  end
end
