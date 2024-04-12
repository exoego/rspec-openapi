# frozen_string_literal: true

# Extractor for rails
class << RSpec::OpenAPI::Extractors::Rails = Object.new
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

    # Reverse the destructive modification by Rails https://github.com/rails/rails/blob/v6.0.3.4/actionpack/lib/action_dispatch/journey/router.rb#L33-L41
    fixed_request = request.dup
    fixed_request.path_info = File.join(request.script_name, request.path_info) if request.script_name.present?

    route, path = find_rails_route(fixed_request)
    raise "No route matched for #{fixed_request.request_method} #{fixed_request.path_info}" if route.nil?

    path = path.delete_suffix('(.:format)')
    summary ||= route.requirements[:action]
    tags ||= [route.requirements[:controller]&.classify].compact
    # :controller and :action always exist. :format is added when routes is configured as such.
    # TODO: Use .except(:controller, :action, :format) when we drop support for Ruby 2.x
    raw_path_params = raw_path_params.slice(*(raw_path_params.keys - RSpec::OpenAPI.ignored_path_params))

    summary ||= "#{request.method} #{path}"

    [path, summary, tags, operation_id, required_request_params, raw_path_params, description, security, deprecated]
  end

  # @param [RSpec::ExampleGroups::*] context
  def request_response(context)
    [context.request, context.response]
  end

  # @param [ActionDispatch::Request] request
  def find_rails_route(request, app: Rails.application, path_prefix: '')
    app.routes.router.recognize(request) do |route|
      path = route.path.spec.to_s
      if route.app.matches?(request)
        if route.app.engine?
          route, path = find_rails_route(request, app: route.app.app, path_prefix: path)
          next if route.nil?
        end
        return [route, path_prefix + path]
      end
    end

    nil
  end
end
