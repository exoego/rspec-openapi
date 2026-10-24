# frozen_string_literal: true

require 'yaml'
require 'date'

# Builds the document with symbol keys straight from the parser events.
# YAML.safe_load builds a tree of Psych nodes first and hands back string keys,
# which KeyTransformer.symbolize then converted in a copy of the whole document.
# The names of examples are normalized on the way, as that copy did.
#
# Anchors, tags and merge keys are left to YAML.safe_load, which accepts or
# rejects them as it always did. An alias follows its anchor, so it never gets
# this far.
class RSpec::OpenAPI::YAMLLoader < Psych::Handler
  class Unsupported < StandardError; end
  private_constant :Unsupported

  PERMITTED_CLASSES = [Date, Time].freeze
  # Marks a mapping waiting for its next key, as the key itself may be nil.
  NONE = Object.new.freeze
  private_constant :NONE

  # @param [String] yaml
  # @return [Object, nil] the first document, or nil when there is none
  def self.load(yaml)
    loader = new
    Psych::Parser.new(loader).parse(yaml)
    loader.root
  rescue Unsupported
    RSpec::OpenAPI::KeyTransformer.symbolize(YAML.safe_load(yaml, permitted_classes: PERMITTED_CLASSES))
  end

  def initialize
    super
    class_loader = Psych::ClassLoader::Restricted.new(PERMITTED_CLASSES.map(&:name), [])
    @scanner = Psych::ScalarScanner.new(class_loader)
    @documents = []
    @containers = [@documents]
    # Per open mapping: the key waiting for its value, and whether the mapping
    # holds named examples.
    @pending_keys = []
    @examples_maps = []
  end

  def root
    @documents.first
  end

  def scalar(value, anchor, tag, _plain, quoted, _style) # rubocop:disable Metrics/ParameterLists
    supported!(anchor, tag, value)
    add(quoted ? value : @scanner.tokenize(value))
  end

  def start_sequence(anchor, tag, _implicit, _style)
    supported!(anchor, tag)
    @containers.push(add([]))
  end

  def end_sequence
    @containers.pop
  end

  def start_mapping(anchor, tag, _implicit, _style)
    supported!(anchor, tag)
    @examples_maps.push(@containers.last.is_a?(Hash) && @pending_keys.last == :examples)
    @containers.push(add({}))
    @pending_keys.push(NONE)
  end

  def end_mapping
    @containers.pop
    @pending_keys.pop
    @examples_maps.pop
  end

  private

  # A `<<` key merges its value into the mapping, so it is handed off too.
  def supported!(anchor, tag, value = nil)
    raise Unsupported if anchor || tag || value == '<<'
  end

  # Values arrive in document order: onto the open sequence, or as the key and
  # then the value of the open mapping. The documents are the outermost
  # sequence.
  def add(value)
    container = @containers.last
    if container.is_a?(Array)
      container << value
    elsif @pending_keys.last.equal?(NONE)
      @pending_keys[-1] = key_for(value)
    else
      container[@pending_keys[-1]] = value
      @pending_keys[-1] = NONE
    end
    value
  end

  def key_for(key)
    key = RSpec::OpenAPI::ExampleKey.normalize(key) if @examples_maps.last && key.is_a?(String)
    key.to_sym
  end
end
