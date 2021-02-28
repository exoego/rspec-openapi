require 'rspec/openapi/version'
require 'rspec/openapi/hooks' if ENV['OPENAPI']

module RSpec::OpenAPI
  @application_version = '1.0.0'
  @comment = nil
  @description = nil
  @response_description_builder = -> (example) { example.metadata[:result] }
  @operation_description_builder = -> (example) { example.metadata[:description] }
  @enable_example = true
  @path = 'doc/openapi.yaml'
  @summary_builder = -> (example) { example.metadata[:summary] }
  @tags = []
  @title = 'app'

  class << self
    ACCESSORS = %i(
      application_version
      comment
      description
      description_builder
      enable_example
      operation_description_builder
      path
      response_description_builder
      summary_builder
      tags
      title
    )

    attr_accessor(*ACCESSORS)
  end
end
