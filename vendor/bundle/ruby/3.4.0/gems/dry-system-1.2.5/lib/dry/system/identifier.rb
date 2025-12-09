# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    # An identifier representing a component to be registered.
    #
    # Components are eventually registered in the container using plain string
    # identifiers, available as the `identifier` or `key` attribute here. Additional
    # methods are provided to make it easier to evaluate or manipulate these identifiers.
    #
    # @api public
    class Identifier
      include Dry::Equalizer(:key)

      # @return [String] the identifier's string key
      # @api public
      attr_reader :key

      # @api private
      def initialize(key)
        @key = key.to_s
      end

      # @!method to_s
      #   Returns the identifier string key
      #
      #   @return [String]
      #   @see #key
      #   @api public
      alias_method :to_s, :key

      # Returns the root namespace segment of the identifier string, as a symbol
      #
      # @example
      #   identifier.key # => "articles.operations.create"
      #   identifier.root_key # => :articles
      #
      # @return [Symbol] the root key
      # @api public
      def root_key
        segments.first.to_sym
      end

      # Returns true if the given leading segments string is a leading part of the {key}.
      #
      # Also returns true if nil or an empty string is given.
      #
      # @example
      #   identifier.key # => "articles.operations.create"
      #
      #   identifier.start_with?("articles.operations") # => true
      #   identifier.start_with?("articles") # => true
      #   identifier.start_with?("article") # => false
      #   identifier.start_with?(nil) # => true
      #
      # @param leading_segments [String] the one or more leading segments to check
      # @return [Boolean]
      # @api public
      def start_with?(leading_segments)
        leading_segments.to_s.empty? ||
          key.start_with?("#{leading_segments}#{KEY_SEPARATOR}") ||
          key.eql?(leading_segments)
      end

      # Returns true if the given trailing segments string is the end part of the {key}.
      #
      # Also returns true if nil or an empty string is given.
      #
      # @example
      #   identifier.key # => "articles.operations.create"
      #
      #   identifier.end_with?("create") # => true
      #   identifier.end_with?("operations.create") # => true
      #   identifier.end_with?("ate") # => false, not a whole segment
      #   identifier.end_with?("nup") # => false, not in key at all
      #
      # @param trailing_segments [String] the one or more trailing key segments to check
      # @return [Boolean]
      # @api public
      def end_with?(trailing_segments)
        trailing_segments.to_s.empty? ||
          key.end_with?("#{KEY_SEPARATOR}#{trailing_segments}") ||
          key.eql?(trailing_segments)
      end

      # Returns true if the given segments string matches whole segments within the {key}.
      #
      # @example
      #   identifier.key # => "articles.operations.create"
      #
      #   identifier.include?("operations") # => true
      #   identifier.include?("articles.operations") # => true
      #   identifier.include?("operations.create") # => true
      #
      #   identifier.include?("article") # => false, not a whole segment
      #   identifier.include?("update") # => false, not in key at all
      #
      # @param segments [String] the one of more key segments to check
      # @return [Boolean]
      # @api public
      def include?(segments)
        return false if segments.to_s.empty?

        sep_re = Regexp.escape(KEY_SEPARATOR)
        key.match?(
          /
            (\A|#{sep_re})
            #{Regexp.escape(segments)}
            (\Z|#{sep_re})
          /x
        )
      end

      # Returns the key with its segments separated by the given separator
      #
      # @example
      #   identifier.key # => "articles.operations.create"
      #   identifier.key_with_separator("/") # => "articles/operations/create"
      #
      # @return [String] the key using the separator
      # @api private
      def key_with_separator(separator)
        segments.join(separator)
      end

      # Returns a copy of the identifier with the key's leading namespace(s) replaced
      #
      # @example Changing a namespace
      #   identifier.key # => "articles.operations.create"
      #   identifier.namespaced(from: "articles", to: "posts").key # => "posts.commands.create"
      #
      # @example Removing a namespace
      #   identifier.key # => "articles.operations.create"
      #   identifier.namespaced(from: "articles", to: nil).key # => "operations.create"
      #
      # @example Adding a namespace
      #   identifier.key # => "articles.operations.create"
      #   identifier.namespaced(from: nil, to: "admin").key # => "admin.articles.operations.create"
      #
      # @param from [String, nil] the leading namespace(s) to replace
      # @param to [String, nil] the replacement for the leading namespace
      #
      # @return [Dry::System::Identifier] the copy of the identifier
      #
      # @see #initialize
      # @api private
      def namespaced(from:, to:)
        return self if from == to

        separated_to = "#{to}#{KEY_SEPARATOR}" if to

        new_key =
          if from.nil?
            "#{separated_to}#{key}"
          else
            key.sub(
              /^#{Regexp.escape(from.to_s)}#{Regexp.escape(KEY_SEPARATOR)}/,
              separated_to || EMPTY_STRING
            )
          end

        return self if new_key == key

        self.class.new(new_key)
      end

      private

      def segments
        @segments ||= key.split(KEY_SEPARATOR)
      end
    end
  end
end
