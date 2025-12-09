# frozen_string_literal: true

module Dry
  module System
    # An indirect component is a component that cannot be directly from a source file
    # directly managed by the container. It may be component that needs to be loaded
    # indirectly, either via a registration manifest file or an imported container
    #
    # Indirect components are an internal abstraction and, unlike ordinary components, are
    # not exposed to users via component dir configuration hooks.
    #
    # @see Container#load_component
    # @see Container#find_component
    #
    # @api private
    class IndirectComponent
      include Dry::Equalizer(:identifier)

      # @!attribute [r] identifier
      #   @return [String] the component's unique identifier
      attr_reader :identifier

      # @api private
      def initialize(identifier)
        @identifier = identifier
      end

      # Returns false, indicating that the component is not directly loadable from the
      # files managed by the container
      #
      # This is the inverse of {Component#loadable?}
      #
      # @return [FalseClass]
      #
      # @api private
      def loadable?
        false
      end

      # Returns the component's unique key
      #
      # @return [String] the key
      #
      # @see Identifier#key
      #
      # @api private
      def key
        identifier.to_s
      end

      # Returns the root namespace segment of the component's key, as a symbol
      #
      # @see Identifier#root_key
      #
      # @return [Symbol] the root key
      #
      # @api private
      def root_key
        identifier.root_key
      end
    end
  end
end
