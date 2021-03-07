class << RSpec::OpenAPI::DefaultSchema = Object.new
  def build(title)
    {
      openapi: '3.0.3',
      info: {
        title: RSpec::OpenAPI.title,
        version: RSpec::OpenAPI.application_version,
      },
      paths: {},
    }.tap { |h|
      h[:tags] = RSpec::OpenAPI.tags if RSpec::OpenAPI.tags.any?
      h[:info][:description] = RSpec::OpenAPI.description if RSpec::OpenAPI.description
      h[:servers] = RSpec::OpenAPI.servers if RSpec::OpenAPI.servers
    }.freeze
  end
end
