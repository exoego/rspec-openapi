require 'rspec/openapi/version'
require 'rspec/openapi/hooks' if ENV['OPENAPI']

module RSpec::OpenAPI
  @application_version = '1.0.0'
  @comment = nil
  @description = nil
  @response_description_builder = -> (example) { example.metadata[:result] }
  @enable_example = true
  @operation_description_builder = -> (example) { example.metadata[:description] }
  @path = 'doc/openapi.yaml'
  @servers = []
  @summary_builder = -> (example) { example.metadata[:summary] }
  @tags = []
  @tags_builder = nil
  @title = 'app'
  @whitelisted_parameter_headers = []

  class << self
    attr_accessor \
      :application_version,
      :comment,
      :description,
      :description_builder,
      :enable_example,
      :operation_description_builder,
      :path,
      :response_description_builder,
      :servers,
      :summary_builder,
      :tags,
      :tags_builder,
      :title,
      :whitelisted_parameter_headers
  end
end
