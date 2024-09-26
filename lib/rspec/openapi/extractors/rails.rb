# frozen_string_literal: true

# Extractor for rails
class << RSpec::OpenAPI::Extractors::Rails = Object.new
  # @param [ActionDispatch::Request] request
  # @param [RSpec::Core::Example] example
  # @return Array
  def request_attributes(request, example)
    # Reverse the destructive modification by Rails https://github.com/rails/rails/blob/v6.0.3.4/actionpack/lib/action_dispatch/journey/router.rb#L33-L41
    fixed_request = request.dup
    fixed_request.path_info = File.join(request.script_name, request.path_info) if request.script_name.present?

    route, path = find_rails_route(fixed_request)

    raise "No route matched for #{fixed_request.request_method} #{fixed_request.path_info}" if route.nil?

    return RSpec::OpenAPI::Extractors::Rack.request_attributes(request, example) unless path

    metadata = example.metadata[:openapi] || {}
    summary = metadata[:summary] || RSpec::OpenAPI.summary_builder.call(example)
    tags = metadata[:tags] || RSpec::OpenAPI.tags_builder.call(example)
    operation_id = metadata[:operation_id]
    required_request_params = metadata[:required_request_params] || []
    optional_request_params = metadata[:optional_request_params] || []
    optional_headers = metadata[:optional_headers] || []
    security = metadata[:security]
    description = metadata[:description] || RSpec::OpenAPI.description_builder.call(example)
    deprecated = metadata[:deprecated]
    raw_path_params = request.path_parameters

    summary ||= route.requirements[:action]
    tags ||= [route.requirements[:controller]&.classify].compact
    # :controller and :action always exist. :format is added when routes is configured as such.
    # TODO: Use .except(:controller, :action, :format) when we drop support for Ruby 2.x
    raw_path_params = raw_path_params.slice(*(raw_path_params.keys - RSpec::OpenAPI.ignored_path_params))

    summary ||= "#{request.method} #{path}"

    [path, summary, tags, operation_id, required_request_params, optional_request_params, optional_headers, raw_path_params, description, security, deprecated]
  end

  # @param [RSpec::ExampleGroups::*] context
  def request_response(context)
    [context.request, context.response]
  end

  # @param [ActionDispatch::Request] request
  def find_rails_route(request, app: Rails.application, path_prefix: '')
    app.routes.router.recognize(request) do |route, _parameters|
      path = route.path.spec.to_s.delete_suffix('(.:format)')

      if route.app.matches?(request)
        if route.app.engine?
          route, path = find_rails_route(request, app: route.app.app, path_prefix: path)
          next if route.nil?
        end

        # Params are empty when it is Engine or Rack app.
        # In that case, we can't handle parameters in path.
        return [route, nil] if request.params.empty?

        return [route, path_prefix + path]
      end
    end

    nil
  end
end
