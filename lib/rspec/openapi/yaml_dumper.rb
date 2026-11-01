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

  # Stands in for the emitter while the superclass writes a string, to keep
  # the arguments of the one scalar call it makes.
  class Recorder
    attr_reader :scalar_arguments

    def initialize(emitter)
      @emitter = emitter
    end

    def scalar(value, anchor, tag, plain, quoted, style) # rubocop:disable Metrics/ParameterLists
      # The emitter copies a string of any encoding but UTF-8 on every call.
      value = value.dup.force_encoding(Encoding::UTF_8) if value.encoding != Encoding::UTF_8 && value.ascii_only?
      @scalar_arguments = [value, tag, plain, quoted, style].freeze
      @emitter.scalar(value, anchor, tag, plain, quoted, style)
    end
  end
  private_constant :Recorder

  def initialize(emitter, scanner, options)
    super
    # How a string is written takes several regexp matches to decide, and a
    # document repeats its keys and the names of its types thousands of times.
    # So the decision is kept by key, which saves the string of the key too,
    # and by string.
    @key_scalars = {}.compare_by_identity
    @string_scalars = {}
  end

  def visit_Hash(hash) # rubocop:disable Naming/MethodName
    @emitter.start_mapping(nil, nil, true, Psych::Nodes::Mapping::BLOCK)
    hash.each do |key, value|
      emit_key(key)
      accept(value)
    end
    @emitter.end_mapping
  end

  def visit_Array(array) # rubocop:disable Naming/MethodName
    @emitter.start_sequence(nil, nil, true, Psych::Nodes::Sequence::BLOCK)
    array.each { |item| accept(item) }
    @emitter.end_sequence
  end

  def visit_String(string) # rubocop:disable Naming/MethodName
    scalar = @string_scalars[string]
    return emit_scalar(scalar) if scalar

    @string_scalars[string] = recording { super }
  end

  private

  def emit_key(key)
    scalar = @key_scalars[key]
    return emit_scalar(scalar) if scalar

    name = key.to_s
    visit_String(name)
    @key_scalars[key] = @string_scalars[name]
  end

  def emit_scalar(scalar)
    @emitter.scalar(scalar[0], nil, scalar[1], scalar[2], scalar[3], scalar[4])
  end

  def recording
    emitter = @emitter
    @emitter = recorder = Recorder.new(emitter)
    yield
    recorder.scalar_arguments
  ensure
    @emitter = emitter
  end

  # :nocov:
  # Reached by values other than hashes, arrays and plain scalars, such as the
  # dates of a hand-written document, which the suite does not hold.
  def register(_target, yaml_obj)
    yaml_obj
  end
  # :nocov:
end
