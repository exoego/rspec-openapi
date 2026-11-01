# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaBuilder
  # Lookup context threaded through schema building. Bundles the metadata
  # needed to resolve formats, enums, and additionalProperties overrides for
  # a value at a given path under a record's request/response side.
  #
  # Positional members: one is built per property of every body, and
  # keyword_init would add a keyword hash to each. The path is only ever looked
  # up in the enum and additionalProperties maps of the record, so it is built
  # for a side of a record that holds one.
  BuildContext = Struct.new(:record, :context, :path, :key, :lookups) do
    def self.root(record, context, path = nil, key = nil)
      lookups = record[ENUM_MEMBERS.fetch(context)] ||
                OVERRIDE_MEMBERS.any? { |_kind, members| record[members.fetch(context)] }
      new(record, context, path, key, lookups)
    end

    def descend(child_key)
      self.class.new(record, context, child_path(child_key), child_key, lookups)
    end

    def child_path(child_key)
      return nil unless lookups

      path ? "#{path}.#{child_key}" : child_key.to_s
    end

    def for_array_items
      self.class.new(record, context, path, nil, lookups)
    end
  end
  private_constant :BuildContext
end
