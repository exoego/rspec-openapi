# frozen_string_literal: true

class SharedExtractor
  def self.attributes(example)
    metadata = merge_openapi_metadata(example.metadata)
    summary = metadata[:summary] || RSpec::OpenAPI.summary_builder.call(example)
    tags = metadata[:tags] || RSpec::OpenAPI.tags_builder.call(example)
    formats = metadata[:formats] || RSpec::OpenAPI.formats_builder.curry.call(example)
    operation_id = metadata[:operation_id]
    required_request_params = metadata[:required_request_params] || []
    security = metadata[:security]
    description = metadata[:description] || RSpec::OpenAPI.description_builder.call(example)
    deprecated = metadata[:deprecated]
    enable_examples = metadata[:enable_examples]
    example_description = if enable_examples
                            metadata[:example_description] || RSpec::OpenAPI.examples_description_builder.call(example)
                          end

    [summary, tags, formats, operation_id, required_request_params, security, description, deprecated, enable_examples,
     example_description,]
  end

  def self.merge_openapi_metadata(metadata)
    collect_openapi_metadata(metadata).reduce({}, &:merge)
  end

  def self.collect_openapi_metadata(metadata)
    [].tap do |result|
      current = metadata

      while current
        [current[:example_group], current].each do |meta|
          result.unshift(meta[:openapi]) if meta&.dig(:openapi)
        end

        current = current[:parent_example_group]
      end
    end
  end
end
