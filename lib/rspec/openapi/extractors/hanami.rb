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
  # @param [RSpec::ExampleGroups::*] context
  # @param [RSpec::Core::Example] example
  # @return Array
  def request_attributes(request, example)
    summary, tags, operation_id, required_request_params, security, description, deprecated, enable_examples,
      example_description = SharedExtractor.attributes(example)

    path = request.path

    route = Hanami.app.router.recognize(request.path, method: request.method)

    raw_path_params = route.params.filter { |_key, value| number_or_nil(value) }

    result = InspectorAnalyzer.call(request.method, add_id(path, route))

    summary ||= result[:summary]
    tags ||= result[:tags]
    path = add_openapi_id(path, route)

    raw_path_params = raw_path_params.slice(*(raw_path_params.keys - RSpec::OpenAPI.ignored_path_params))

    [path, summary, tags, operation_id, required_request_params, raw_path_params, description, security, deprecated,
     enable_examples, example_description,]
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
      next unless number_or_nil(value)

      path = path.sub("/#{value}", "/:#{key}")
    end

    path
  end

  def add_openapi_id(path, route)
    return path if route.params.empty?

    route.params.each_pair do |key, value|
      next unless number_or_nil(value)

      path = path.sub("/#{value}", "/{#{key}}")
    end

    path
  end

  def number_or_nil(string)
    Integer(string || '')
  rescue ArgumentError
    nil
  end
end
