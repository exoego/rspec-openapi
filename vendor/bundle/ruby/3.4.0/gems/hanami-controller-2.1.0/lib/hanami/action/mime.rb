# frozen_string_literal: true

require "hanami/utils"
require "rack/utils"
require "rack/mime"
require_relative "errors"

module Hanami
  class Action
    module Mime # rubocop:disable Metrics/ModuleLength
      # Most commom MIME Types used for responses
      #
      # @since 1.0.0
      # @api private
      TYPES = {
        txt: "text/plain",
        html: "text/html",
        json: "application/json",
        manifest: "text/cache-manifest",
        atom: "application/atom+xml",
        avi: "video/x-msvideo",
        bmp: "image/bmp",
        bz: "application/x-bzip",
        bz2: "application/x-bzip2",
        chm: "application/vnd.ms-htmlhelp",
        css: "text/css",
        csv: "text/csv",
        flv: "video/x-flv",
        gif: "image/gif",
        gz: "application/x-gzip",
        h264: "video/h264",
        ico: "image/vnd.microsoft.icon",
        ics: "text/calendar",
        jpg: "image/jpeg",
        js: "application/javascript",
        mp4: "video/mp4",
        mov: "video/quicktime",
        mp3: "audio/mpeg",
        mp4a: "audio/mp4",
        mpg: "video/mpeg",
        oga: "audio/ogg",
        ogg: "application/ogg",
        ogv: "video/ogg",
        pdf: "application/pdf",
        pgp: "application/pgp-encrypted",
        png: "image/png",
        psd: "image/vnd.adobe.photoshop",
        rss: "application/rss+xml",
        rtf: "application/rtf",
        sh: "application/x-sh",
        svg: "image/svg+xml",
        swf: "application/x-shockwave-flash",
        tar: "application/x-tar",
        torrent: "application/x-bittorrent",
        tsv: "text/tab-separated-values",
        uri: "text/uri-list",
        vcs: "text/x-vcalendar",
        wav: "audio/x-wav",
        webm: "video/webm",
        wmv: "video/x-ms-wmv",
        woff: "application/font-woff",
        woff2: "application/font-woff2",
        wsdl: "application/wsdl+xml",
        xhtml: "application/xhtml+xml",
        xml: "application/xml",
        xslt: "application/xslt+xml",
        yml: "text/yaml",
        zip: "application/zip"
      }.freeze

      ANY_TYPE = "*/*"

      class << self
        # Returns a format name for the given content type.
        #
        # The format name will come from the configured formats, if such a format is configured
        # there, or instead from the default list of formats in `Mime::TYPES`.
        #
        # Returns nil if no matching format can be found.
        #
        # This is used to return the format name a {Response}.
        #
        # @example
        #   detect_format("application/jsonl charset=utf-8", config) # => :json
        #
        # @return [Symbol, nil]
        #
        # @see Response#format
        # @see Action#finish
        #
        # @since 2.0.0
        # @api private
        def detect_format(content_type, config)
          return if content_type.nil?

          ct = content_type.split(";").first
          config.formats.format_for(ct) || TYPES.key(ct)
        end

        # Returns a format name and content type pair for a given format name or content type
        # string.
        #
        # @example
        #   detect_format_and_content_type(:json, config)
        #   # => [:json, "application/json"]
        #
        #   detect_format_and_content_type("application/json", config)
        #   # => [:json, "application/json"]
        #
        # @example Unknown format name
        #   detect_format_and_content_type(:unknown, config)
        #   # raises Hanami::Action::UnknownFormatError
        #
        # @example Unknown content type
        #   detect_format_and_content_type("application/unknown", config)
        #   # => [nil, "application/unknown"]
        #
        # @return [Array<(Symbol, String)>]
        #
        # @raise [Hanami::Action::UnknownFormatError] if an unknown format name is given
        #
        # @since 2.0.0
        # @api private
        def detect_format_and_content_type(value, config)
          case value
          when Symbol
            [value, format_to_mime_type(value, config)]
          when String
            [detect_format(value, config), value]
          else
            raise UnknownFormatError.new(value)
          end
        end

        # Returns a string combining the given content type and charset, intended for setting as a
        # `Content-Type` header.
        #
        # @example
        #   Mime.content_type_with_charset("application/json", "utf-8")
        #   # => "application/json; charset=utf-8"
        #
        # @param content_type [String]
        # @param charset [String]
        #
        # @return [String]
        #
        # @since 2.0.0
        # @api private
        def content_type_with_charset(content_type, charset)
          "#{content_type}; charset=#{charset}"
        end

        # Returns a string combining a MIME type and charset, intended for setting as the
        # `Content-Type` header for the response to the given request.
        #
        # This uses the request's `Accept` header (if present) along with the configured formats to
        # determine the best content type to return.
        #
        # @return [String]
        #
        # @see Action#call
        #
        # @since 2.0.0
        # @api private
        def response_content_type_with_charset(request, config)
          content_type_with_charset(
            response_content_type(request, config),
            config.default_charset || Action::DEFAULT_CHARSET
          )
        end

        # Patched version of <tt>Rack::Utils.best_q_match</tt>.
        #
        # @since 2.0.0
        # @api private
        #
        # @see http://www.rubydoc.info/gems/rack/Rack/Utils#best_q_match-class_method
        # @see https://github.com/rack/rack/pull/659
        # @see https://github.com/hanami/controller/issues/59
        # @see https://github.com/hanami/controller/issues/104
        # @see https://github.com/hanami/controller/issues/275
        def best_q_match(q_value_header, available_mimes = TYPES.values)
          ::Rack::Utils.q_values(q_value_header).each_with_index.map { |(req_mime, quality), index|
            match = available_mimes.find { |am| ::Rack::Mime.match?(am, req_mime) }
            next unless match

            RequestMimeWeight.new(req_mime, quality, index, match)
          }.compact.max&.format
        end

        # Yields if an action is configured with `formats`, the request has an `Accept` header, an
        # none of the Accept types matches the accepted formats. The given block is expected to halt
        # the request handling.
        #
        # If any of these conditions are not met, then the request is acceptable and the method
        # returns without yielding.
        #
        # @see Action#enforce_accepted_mime_types
        # @see Config#formats
        #
        # @since 2.0.0
        # @api private
        def enforce_accept(request, config)
          return unless request.accept_header?

          accept_types = ::Rack::Utils.q_values(request.accept).map(&:first)
          return if accept_types.any? { |mime_type| accepted_mime_type?(mime_type, config) }

          yield
        end

        # Yields if an action is configured with `formats`, the request has a `Content-Type` header
        # (or a `default_requst_format` is configured), and the content type does not match the
        # accepted formats. The given block is expected to halt the request handling.
        #
        # If any of these conditions are not met, then the request is acceptable and the method
        # returns without yielding.
        #
        # @see Action#enforce_accepted_mime_types
        # @see Config#formats
        #
        # @since 2.0.0
        # @api private
        def enforce_content_type(request, config)
          content_type = request.content_type

          return if content_type.nil?

          return if accepted_mime_type?(content_type, config)

          yield
        end

        private

        # @since 2.0.0
        # @api private
        def accepted_mime_type?(mime_type, config)
          accepted_mime_types(config).any? { |accepted_mime_type|
            ::Rack::Mime.match?(mime_type, accepted_mime_type)
          }
        end

        # @since 2.0.0
        # @api private
        def accepted_mime_types(config)
          return [ANY_TYPE] if config.formats.empty?

          config.formats.map { |format| format_to_mime_types(format, config) }.flatten(1)
        end

        # @since 2.0.0
        # @api private
        def response_content_type(request, config)
          if request.accept_header?
            all_mime_types = TYPES.values + config.formats.mapping.keys
            content_type = best_q_match(request.accept, all_mime_types)

            return content_type if content_type
          end

          if config.formats.default
            return format_to_mime_type(config.formats.default, config)
          end

          Action::DEFAULT_CONTENT_TYPE
        end

        # @since 2.0.0
        # @api private
        def format_to_mime_type(format, config)
          config.formats.mime_type_for(format) ||
            TYPES.fetch(format) { raise Hanami::Action::UnknownFormatError.new(format) }
        end

        # @since 2.0.0
        # @api private
        def format_to_mime_types(format, config)
          config.formats.mime_types_for(format).tap { |types|
            types << TYPES[format] if TYPES.key?(format)
          }
        end
      end
    end
  end
end
