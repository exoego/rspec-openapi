# frozen_string_literal: true

class << RSpec::OpenAPI::DefaultSchema = Object.new
  def build(title)
    spec = {
      openapi: RSpec::OpenAPI.openapi_version,
      info: {
        title: title,
        version: RSpec::OpenAPI.application_version,
      },
      servers: RSpec::OpenAPI.servers,
      paths: {},
    }

    if RSpec::OpenAPI.security_schemes.present?
      spec[:components] = {
        securitySchemes: RSpec::OpenAPI.security_schemes,
      }
    end

    spec[:tags] = RSpec::OpenAPI.root_tags if RSpec::OpenAPI.root_tags.present?

    spec.freeze
  end
end
