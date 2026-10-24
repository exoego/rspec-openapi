# frozen_string_literal: true

require 'yaml'

# Writes a document straight to the libyaml emitter. YAML.dump first builds a
# tree of Psych nodes and then walks it to make the same emitter calls, so the
# output is the same without the tree. Keys are written as strings, which is
# what they are read back as, so the document needs no stringified copy.
#
# Nothing in a document is shared, so there are no anchors to find and the
# bookkeeping for them is skipped.
class RSpec::OpenAPI::YAMLDumper < Psych::Visitors::YAMLTree
  # @param [Object] object
  # @param [IO, StringIO] io
  def self.dump(object, io)
    dumper = create({}, Psych::Emitter.new(io))
    dumper << object
    dumper.finish
    io
  end

  def visit_Hash(hash) # rubocop:disable Naming/MethodName
    @emitter.start_mapping(nil, nil, true, Psych::Nodes::Mapping::BLOCK)
    hash.each do |key, value|
      visit_String(key.to_s)
      accept(value)
    end
    @emitter.end_mapping
  end

  def visit_Array(array) # rubocop:disable Naming/MethodName
    @emitter.start_sequence(nil, nil, true, Psych::Nodes::Sequence::BLOCK)
    array.each { |item| accept(item) }
    @emitter.end_sequence
  end

  private

  # :nocov:
  # Reached by values other than hashes, arrays and plain scalars, such as the
  # dates of a hand-written document, which the suite does not hold.
  def register(_target, yaml_obj)
    yaml_obj
  end
  # :nocov:
end
