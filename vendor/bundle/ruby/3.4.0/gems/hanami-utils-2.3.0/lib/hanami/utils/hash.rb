# frozen_string_literal: true

require "dry/transformer"

module Hanami
  module Utils
    # Hash transformations
    # @since 0.1.0
    module Hash
      extend Dry::Transformer::Registry

      import Dry::Transformer::HashTransformations

      # Symbolize the given hash
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the symbolized hash
      #
      # @since 1.0.1
      #
      # @see .deep_symbolize
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #
      #   hash = Hanami::Utils::Hash.symbolize("foo" => "bar", "baz" => {"a" => 1})
      #     # => {:foo=>"bar", :baz=>{"a"=>1}}
      #
      #   hash.class
      #     # => Hash
      def self.symbolize(input)
        self[:symbolize_keys].call(input)
      end

      # Performs deep symbolize on the given hash
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the deep symbolized hash
      #
      # @since 1.0.1
      #
      # @see .symbolize
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #
      #   hash = Hanami::Utils::Hash.deep_symbolize("foo" => "bar", "baz" => {"a" => 1})
      #     # => {:foo=>"bar", :baz=>{a:=>1}}
      #
      #   hash.class
      #     # => Hash
      def self.deep_symbolize(input)
        self[:deep_symbolize_keys].call(input)
      end

      # Stringifies the given hash
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the stringified hash
      #
      # @since 1.0.1
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #
      #   hash = Hanami::Utils::Hash.stringify(foo: "bar", baz: {a: 1})
      #     # => {"foo"=>"bar", "baz"=>{:a=>1}}
      #
      #   hash.class
      #     # => Hash
      def self.stringify(input)
        self[:stringify_keys].call(input)
      end

      # Deeply stringifies the given hash
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the deep stringified hash
      #
      # @since 1.1.1
      #
      # @example Basic Usage
      #   require "hanami/utils/hash"
      #
      #   hash = Hanami::Utils::Hash.deep_stringify(foo: "bar", baz: {a: 1})
      #     # => {"foo"=>"bar", "baz"=>{"a"=>1}}
      #
      #   hash.class
      #     # => Hash
      def self.deep_stringify(input)
        self[:deep_stringify_keys].call(input)
      end

      # Deep duplicates hash values
      #
      # The output of this function is a deep duplicate of the input.
      # Any further modification on the input, won't be reflected on the output
      # and viceversa.
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the deep duplicate of input
      #
      # @since 1.0.1
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #
      #   input  = { "a" => { "b" => { "c" => [1, 2, 3] } } }
      #   output = Hanami::Utils::Hash.deep_dup(input)
      #     # => {"a"=>{"b"=>{"c"=>[1,2,3]}}}
      #
      #   output.class
      #     # => Hash
      #
      #
      #
      #   # mutations on input aren't reflected on output
      #
      #   input["a"]["b"]["c"] << 4
      #   output.dig("a", "b", "c")
      #     # => [1, 2, 3]
      #
      #
      #
      #   # mutations on output aren't reflected on input
      #
      #   output["a"].delete("b")
      #   input
      #     # => {"a"=>{"b"=>{"c"=>[1,2,3,4]}}}
      def self.deep_dup(input)
        input.transform_values do |v|
          case v
          when ::Hash
            deep_dup(v)
          else
            v.dup
          end
        end
      end

      # Deep serializes given object into a `Hash`
      #
      # Please note that the returning `Hash` will use symbols as keys.
      #
      # @param input [#to_hash] the input
      #
      # @return [::Hash] the deep serialized hash
      #
      # @since 1.1.0
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #   require 'ostruct'
      #
      #   class Data < OpenStruct
      #     def to_hash
      #       to_h
      #     end
      #   end
      #
      #   input = Data.new("foo" => "bar", baz => [Data.new(hello: "world")])
      #
      #   Hanami::Utils::Hash.deep_serialize(input)
      #     # => {:foo=>"bar", :baz=>[{:hello=>"world"}]}
      def self.deep_serialize(input)
        input.to_hash.each_with_object({}) do |(key, value), output|
          output[key.to_sym] =
            case value
            when ->(h) { h.respond_to?(:to_hash) }
              deep_serialize(value)
            when Array
              value.map do |item|
                item.respond_to?(:to_hash) ? deep_serialize(item) : item
              end
            else
              value
            end
        end
      end
    end
  end
end
