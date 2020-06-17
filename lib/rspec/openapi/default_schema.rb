class << RSpec::OpenAPI::DefaultSchema = Object.new
  def build(title)
    {
      openapi: '3.0.3',
      info: {
        title: title,
      },
      paths: {},
    }.freeze
  end
end
