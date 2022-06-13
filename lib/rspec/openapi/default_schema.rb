class << RSpec::OpenAPI::DefaultSchema = Object.new
  def build(title)
    {
      openapi: '3.0.3',
      info: {
        title: title,
        version: RSpec::OpenAPI.application_version,
      },
      servers: RSpec::OpenAPI.servers,
      paths: {},
    }.freeze
  end
end
