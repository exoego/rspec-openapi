class << RSpec::OpenAPI::DefaultSchema = Object.new
  def build(title)
    {
      openapi: '3.0.3',
      info: {
        title: title,
        version: RSpec::OpenAPI.application_version,
      },
      servers: RSpec::OpenAPI.server_urls.map { |url| { url: url } } || [],
      paths: {},
    }.freeze
  end
end
