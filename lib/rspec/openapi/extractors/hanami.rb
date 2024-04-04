# frozen_string_literal: true
require 'dry/inflector'

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
    raw_path_params = request.path_parameters
    path = request.path
    route = Hanami.app.router.recognize(request.path, method: request.method)

    path = add_id(path, route)
    result = generate_summary_and_tag(path, request.method)
    summary ||= result[0]
    tags ||= result[1]

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

      path = path.sub("/#{value}", "/{#{key}}")
    end

    path
  end

  def generate_summary_and_tag(path, method)
    case path
    when ->(path) { path.end_with?('{id}/edit') && method == 'GET' }
      ['edit', extract_tag(path, '/{id}/edit')]
    when ->(path) { path.end_with?('{id}') && method == 'GET' }
      ['show', extract_tag(path, '/{id}')]
    when ->(path) { path.end_with?('{id}') && %w[PATCH PUT POST].include?(method) }
      ['update', extract_tag(path, '/{id}')]
    when ->(path) { path.end_with?('{id}') && method == 'DELETE' }
      ['destroy', extract_tag(path, '/{id}')]
    when ->(path) { path.end_with?('/new') && method == 'GET' }
      ['new', extract_tag(path, '/new')]
    when ->(_path) { method == 'GET' }
      ['index', extract_tag(path)]
    when ->(_path) { method == 'POST' }
      ['create', extract_tag(path)]
    else
      ["#{method} #{path}", []]
    end
  end

  def extract_tag(path, prefix = nil)
    path = path.delete_suffix(prefix) if prefix

    [inflector.classify(path.split(%r{/+}).last)]
  end

  def inflector
    @inflector ||= Dry::Inflector.new
  end

  def number_or_nil(string)
    Integer(string || '')
  rescue ArgumentError
    nil
  end
end
