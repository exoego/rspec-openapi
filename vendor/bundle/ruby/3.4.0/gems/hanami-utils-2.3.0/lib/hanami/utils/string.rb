# frozen_string_literal: true

require "dry/transformer"
require "concurrent/map"

module Hanami
  module Utils
    # String utilities
    #
    # @since 0.1.0
    module String
      # Empty string for #classify
      #
      # @since 0.6.0
      # @api private
      EMPTY_STRING        = ""

      # Separator between Ruby namespaces
      #
      # @since 0.1.0
      # @api private
      NAMESPACE_SEPARATOR = "::"

      # Separator for #classify
      #
      # @since 0.3.0
      # @api private
      CLASSIFY_SEPARATOR  = "_"

      # Separator for #underscore
      #
      # @since 0.3.0
      # @api private
      UNDERSCORE_SEPARATOR = "/"

      # gsub second parameter used in #underscore
      #
      # @since 0.3.0
      # @api private
      UNDERSCORE_DIVISION_TARGET = '\1_\2'

      # Separator for #titleize
      #
      # @since 0.4.0
      # @api private
      TITLEIZE_SEPARATOR = " "

      # Separator for #capitalize
      #
      # @since 0.5.2
      # @api private
      CAPITALIZE_SEPARATOR = " "

      # Separator for #dasherize
      #
      # @since 0.4.0
      # @api private
      DASHERIZE_SEPARATOR = "-"

      # Regexp for #classify
      #
      # @since 0.3.4
      # @api private
      CLASSIFY_WORD_SEPARATOR = /#{CLASSIFY_SEPARATOR}|#{NAMESPACE_SEPARATOR}|#{UNDERSCORE_SEPARATOR}|#{DASHERIZE_SEPARATOR}/ # rubocop:disable Layout/LineLength

      @__transformations__ = Concurrent::Map.new

      extend Dry::Transformer::Registry

      # Applies the given transformation(s) to `input`
      #
      # It performs a pipeline of transformations, by applying the given
      # functions from `Hanami::Utils::String` and `::String`.
      # The transformations are applied in the given order.
      #
      # It doesn't mutate the input, unless you use destructive methods from `::String`
      #
      # @param input [::String] the string to be transformed
      # @param transformations [Array<Symbol,Proc,Array>] one or many
      #   transformations expressed as:
      #     * `Symbol` to reference a function from `Hanami::Utils::String` or `String`.
      #     * `Proc` an anonymous function that MUST accept one input
      #     * `Array` where the first element is a `Symbol` to reference a
      #       function from `Hanami::Utils::String` or `String` and the rest of
      #       the elements are the arguments to pass
      #
      # @return [::String] the result of the transformations
      #
      # @raise [NoMethodError] if a `Hanami::Utils::String` and `::String`
      #   don't respond to a given method name
      #
      # @raise [ArgumentError] if a Proc transformation has an arity not equal
      #   to 1
      #
      # @since 1.1.0
      #
      # @example Basic usage
      #   require "hanami/utils/string"
      #
      #   Hanami::Utils::String.transform("hanami/utils", :underscore, :classify)
      #     # => "Hanami::Utils"
      #
      #   Hanami::Utils::String.transform("Hanami::Utils::String", [:gsub, /[aeiouy]/, "*"], :demodulize)
      #     # => "H*n*m*"
      #
      #   Hanami::Utils::String.transform("Hanami", ->(s) { s.upcase })
      #     # => "HANAMI"
      #
      # @example Unkown transformation
      #   require "hanami/utils/string"
      #
      #   Hanami::Utils::String.transform("Sakura", :foo)
      #     # => NoMethodError: undefined method `:foo' for "Sakura":String
      #
      # @example Proc with arity not equal to 1
      #   require "hanami/utils/string"
      #
      #   Hanami::Utils::String.transform("Cherry", -> { "blossom" }))
      #     # => ArgumentError: wrong number of arguments (given 1, expected 0)
      #
      def self.transform(input, *transformations)
        fn = @__transformations__.fetch_or_store(transformations.hash) do
          fns = Dry::Transformer::Function.new(->(object) { object })

          transformations.each do |transformation, *args|
            fns = fns.compose(
              if transformation.is_a?(Proc)
                transformation
              elsif contain?(transformation)
                self[transformation, *args]
              elsif input.respond_to?(transformation)
                ->(i) { i.public_send(transformation, *args) }
              else
                raise NoMethodError.new(%(undefined method `#{transformation.inspect}' for #{input.inspect}:#{input.class})) # rubocop:disable Layout/LineLength
              end
            )
          end

          fns
        end

        fn.call(input)
      end

      # Returns a titleized version of the string
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 1.1.0
      #
      # @example
      #   require 'hanami/utils/string'
      #
      #   Hanami::Utils::String.titleize('hanami utils') # => "Hanami Utils"
      def self.titleize(input)
        string = ::String.new(input.to_s)
        underscore(string).split(CLASSIFY_SEPARATOR).map(&:capitalize).join(TITLEIZE_SEPARATOR)
      end

      # Returns a capitalized version of the string
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 1.1.0
      #
      # @example
      #   require 'hanami/utils/string'
      #
      #   Hanami::Utils::String.capitalize('hanami') # => "Hanami"
      #
      #   Hanami::Utils::String.capitalize('hanami utils') # => "Hanami utils"
      #
      #   Hanami::Utils::String.capitalize('Hanami Utils') # => "Hanami utils"
      #
      #   Hanami::Utils::String.capitalize('hanami_utils') # => "Hanami utils"
      #
      #   Hanami::Utils::String.capitalize('hanami-utils') # => "Hanami utils"
      def self.capitalize(input)
        string = ::String.new(input.to_s)
        head, *tail = underscore(string).split(CLASSIFY_SEPARATOR)

        tail.unshift(head.capitalize).join(CAPITALIZE_SEPARATOR)
      end

      # Returns a CamelCase version of the string
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 1.1.0
      #
      # @example
      #   require 'hanami/utils/string'
      #
      #   Hanami::Utils::String.classify('hanami_utils') # => 'HanamiUtils'
      def self.classify(input)
        string = ::String.new(input.to_s)
        words = underscore(string).split(CLASSIFY_WORD_SEPARATOR).map!(&:capitalize)
        delimiters = underscore(string).scan(CLASSIFY_WORD_SEPARATOR)

        delimiters.map! do |delimiter|
          delimiter == CLASSIFY_SEPARATOR ? EMPTY_STRING : NAMESPACE_SEPARATOR
        end

        words.zip(delimiters).join
      end

      # Returns a downcased and underscore separated version of the string
      #
      # Revised version of `ActiveSupport::Inflector.underscore` implementation
      # @see https://github.com/rails/rails/blob/feaa6e2048fe86bcf07e967d6e47b865e42e055b/activesupport/lib/active_support/inflector/methods.rb#L90
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 1.1.0
      #
      # @example
      #   require 'hanami/utils/string'
      #
      #   Hanami::Utils::String.underscore('HanamiUtils') # => 'hanami_utils'
      def self.underscore(input)
        string = ::String.new(input.to_s)
        string.gsub!(NAMESPACE_SEPARATOR, UNDERSCORE_SEPARATOR)
        string.gsub!(NAMESPACE_SEPARATOR, UNDERSCORE_SEPARATOR)
        string.gsub!(/([A-Z\d]+)([A-Z][a-z])/, UNDERSCORE_DIVISION_TARGET)
        string.gsub!(/([a-z\d])([A-Z])/, UNDERSCORE_DIVISION_TARGET)
        string.gsub!(/[[:space:]]|-|\./, UNDERSCORE_DIVISION_TARGET)
        string.downcase
      end

      # Returns a downcased and dash separated version of the string
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 1.1.0
      #
      # @example
      #   require 'hanami/utils/string'
      #
      #   Hanami::Utils::String.dasherize('Hanami Utils') # => 'hanami-utils'

      #   Hanami::Utils::String.dasherize('hanami_utils') # => 'hanami-utils'
      #
      #   Hanami::Utils::String.dasherize('HanamiUtils') # => "hanami-utils"
      def self.dasherize(input)
        string = ::String.new(input.to_s)
        underscore(string).split(CLASSIFY_SEPARATOR).join(DASHERIZE_SEPARATOR)
      end

      # Returns the string without the Ruby namespace of the class
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 1.1.0
      #
      # @example
      #   require 'hanami/utils/string'
      #
      #   Hanami::Utils::String.demodulize('Hanami::Utils::String') # => 'String'
      #
      #   Hanami::Utils::String.demodulize('String') # => 'String'
      def self.demodulize(input)
        ::String.new(input.to_s).split(NAMESPACE_SEPARATOR).last
      end

      # Returns the top level namespace name
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 1.1.0
      #
      # @example
      #   require 'hanami/utils/string'
      #
      #   Hanami::Utils::String.namespace('Hanami::Utils::String') # => 'Hanami'
      #
      #   Hanami::Utils::String.namespace('String') # => 'String'
      def self.namespace(input)
        ::String.new(input.to_s).split(NAMESPACE_SEPARATOR).first
      end

      # Replace the rightmost match of `pattern` with `replacement`
      #
      # If the pattern cannot be matched, it returns the original string.
      #
      # This method does NOT mutate the original string.
      #
      # @param input [::String] the input
      # @param pattern [Regexp, ::String] the pattern to find
      # @param replacement [String] the string to replace
      #
      # @return [::String] the replaced string
      #
      # @since 1.1.0
      #
      # @example
      #   require 'hanami/utils/string'
      #
      #   Hanami::Utils::String.rsub('authors/books/index', %r{/}, '#')
      #     # => 'authors/books#index'
      def self.rsub(input, pattern, replacement)
        string = ::String.new(input.to_s)
        if i = string.rindex(pattern)
          s = string.dup
          s[i] = replacement
          s
        else
          string
        end
      end
    end
  end
end
