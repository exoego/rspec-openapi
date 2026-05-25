# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaBuilder
  # Lookup context threaded through schema building. Bundles the metadata
  # needed to resolve formats, enums, and additionalProperties overrides for
  # a value at a given path under a record's request/response side.
  BuildContext = Struct.new(:record, :context, :path, :key, keyword_init: true) do
    def descend(child_key)
      self.class.new(
        record: record, context: context, key: child_key,
        path: path ? "#{path}.#{child_key}" : child_key.to_s,
      )
    end

    def for_array_items
      self.class.new(record: record, context: context, path: path, key: nil)
    end
  end
  private_constant :BuildContext
end
