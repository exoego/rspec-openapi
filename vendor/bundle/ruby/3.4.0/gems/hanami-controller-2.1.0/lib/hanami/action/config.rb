# frozen_string_literal: true

require "dry/configurable"

module Hanami
  class Action
    # Config for `Hanami::Action` classes.
    #
    # @see Hanami::Action.config
    #
    # @api public
    # @since 2.0.0
    class Config < Dry::Configurable::Config
      # Default public directory
      #
      # This serves as the root directory for file downloads
      #
      # @since 1.0.0
      #
      # @api private
      DEFAULT_PUBLIC_DIRECTORY = "public"

      # @!attribute [rw] handled_exceptions
      #
      #   Specifies how to handle exceptions with an HTTP status.
      #
      #   Raised exceptions will return the corresponding HTTP status.
      #
      #   @return [Hash{Exception=>Integer}] exception classes as keys and HTTP statuses as values
      #
      #   @example
      #     config.handled_exceptions = {ArgumentError => 400}
      #
      #   @since 0.2.0

      # Specifies how to handle exceptions with an HTTP status
      #
      # Raised exceptions will return the corresponding HTTP status
      #
      # The specified exceptions will be merged with any previously configured
      # exceptions
      #
      # @param exceptions [Hash{Exception=>Integer}] exception classes as keys
      #   and HTTP statuses as values
      #
      # @return [void]
      #
      # @example
      #   config.handle_exceptions(ArgumentError => 400}
      #
      # @see handled_exceptions
      #
      # @since 0.2.0
      def handle_exception(exceptions)
        self.handled_exceptions = handled_exceptions
          .merge(exceptions)
          .sort { |(ex1, _), (ex2, _)| ex1.ancestors.include?(ex2) ? -1 : 1 }
          .to_h
      end

      # @!attribute [r] formats
      #   Returns the format config for the action.
      #
      #   @return [Config::Formats]
      #
      #   @since 2.0.0
      #   @api public

      # Sets the format (or formats) for the action.
      #
      # To configure custom formats and MIME type mappings, call {Formats#add formats.add} first.
      #
      # @example
      #   config.format :html, :json
      #
      # @param formats [Array<Symbol>] the format names
      #
      # @return [Array<Symbol>] the given format names
      #
      # @see #formats
      #
      # @since 2.0.0
      # @api public
      def format(*formats)
        if formats.empty?
          self.formats.values
        else
          self.formats.values = formats
        end
      end

      # @!attribute [rw] default_charset
      #
      #   Sets a charset (character set) as default fallback for all the requests
      #   without a strict requirement for the charset.
      #
      #   By default, this value is nil.
      #
      #   @return [String]
      #
      #   @see Hanami::Action::Mime
      #
      #   @since 0.3.0

      # @!attribute [rw] default_headers
      #
      #   Sets default headers for all responses.
      #
      #   By default, this is an empty hash.
      #
      #   @return [Hash{String=>String}] the headers
      #
      #   @example
      #     config.default_headers = {"X-Frame-Options" => "DENY"}
      #
      #   @see default_headers
      #
      #   @since 0.4.0

      # @!attribute [rw] cookies
      #
      #   Sets default cookie options for all responses.
      #
      #   By default this, is an empty hash.
      #
      #   @return [Hash{Symbol=>String}] the cookie options
      #
      #   @example
      #     config.cookies = {
      #       domain: "hanamirb.org",
      #       path: "/controller",
      #       secure: true,
      #       httponly: true
      #     }
      #
      #   @since 0.4.0

      # @!attribute [rw] root_directory
      #
      #   Sets the the for the public directory, which is used for file downloads.
      #   This must be an existent directory.
      #
      #   Defaults to the current working directory.
      #
      #   @return [String] the directory path
      #
      #   @api private
      #
      #   @since 1.0.0

      # @!attribute [rw] public_directory
      #
      # Sets the path to public directory. This directory is used for file downloads.
      #
      # This given directory will be appended onto the root directory.
      #
      # By default, the public directory is `"public"`.
      # @return [String] the public directory path
      #
      # @example
      #   config.public_directory = "public"
      #   config.public_directory # => "/path/to/root/public"
      #
      # @see root_directory
      #
      # @since 2.0.0
      def public_directory
        # This must be a string, for Rack compatibility
        root_directory.join(super).to_s
      end
    end
  end
end
