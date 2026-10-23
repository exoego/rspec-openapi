# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaBuilder
  # Lookup context threaded through schema building. Bundles the metadata
  # needed to resolve formats, enums, and additionalProperties overrides for
  # a value at a given path under a record's request/response side.
  #
  # Positional members: one is built per property of every body, and
  # keyword_init would add a keyword hash to each.
  BuildContext = Struct.new(:record, :context, :path, :key) do
    def descend(child_key)
      self.class.new(record, context, path ? "#{path}.#{child_key}" : child_key.to_s, child_key)
    end

    def for_array_items
      self.class.new(record, context, path, nil)
    end
  end
  private_constant :BuildContext
end
