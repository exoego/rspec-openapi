# frozen_string_literal: true

class SharedExtractor
  def self.attributes(example)
    metadata = example.metadata[:openapi] || {}
    summary = metadata[:summary] || RSpec::OpenAPI.summary_builder.call(example)
    tags = metadata[:tags] || RSpec::OpenAPI.tags_builder.call(example)
    operation_id = metadata[:operation_id]
    required_request_params = metadata[:required_request_params] || []
    security = metadata[:security]
    description = metadata[:description] || RSpec::OpenAPI.description_builder.call(example)
    deprecated = metadata[:deprecated]
    enable_examples = metadata[:enable_examples]
    example_description = if enable_examples
                            metadata[:example_description] || RSpec::OpenAPI.examples_description_builder.call(example)
                          end

    [summary, tags, operation_id, required_request_params, security, description, deprecated, enable_examples,
     example_description,]
  end
end
