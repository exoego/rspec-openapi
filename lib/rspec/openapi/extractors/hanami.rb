# frozen_string_literal: true

require 'dry/inflector'
require 'hanami'

# Hanami::Router::Inspector original code
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

# Monkey-patch hanami-router
module Hanami::Slice::ClassMethods
  def router(inspector: InspectorAnalyzer)
    raise SliceLoadError, "#{self} must be prepared before loading the router" unless prepared?

    @_mutex.synchronize do
      @_router ||= load_router(inspector: inspector)
    end
  end
end

# Extractor for hanami
class << RSpec::OpenAPI::Extractors::Hanami = Object.new
  # @param [RSpec::ExampleGroups::*] context
  # @param [RSpec::Core::Example] example
  # @return Array
  def request_attributes(request, example)
    metadata = example.metadata[:openapi] || {}
    summary = metadata[:summary] || RSpec::OpenAPI.summary_builder.call(example)
    tags = metadata[:tags] || RSpec::OpenAPI.tags_builder.call(example)
    operation_id = metadata[:operation_id]
    required_request_params = metadata[:required_request_params] || []
    security = metadata[:security]
    description = metadata[:description] || RSpec::OpenAPI.description_builder.call(example)
    deprecated = metadata[:deprecated]
    path = request.path

    route = Hanami.app.router.recognize(request.path, method: request.method)

    raw_path_params = route.params.filter { |_key, value| number_or_nil(value) }

    result = InspectorAnalyzer.call(request.method, add_id(path, route))

    summary ||= result[:summary]
    tags ||= result[:tags]
    path = add_openapi_id(path, route)

    raw_path_params = raw_path_params.slice(*(raw_path_params.keys - RSpec::OpenAPI.ignored_path_params))

    [path, summary, tags, operation_id, required_request_params, raw_path_params, description, security, deprecated]
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
