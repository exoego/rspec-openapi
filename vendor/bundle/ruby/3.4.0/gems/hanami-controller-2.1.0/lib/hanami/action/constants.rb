# frozen_string_literal: true

require "rack"

module Hanami
  class Action
    # Rack SPEC response code
    #
    # @since 1.0.0
    # @api private
    RESPONSE_CODE = 0

    # Rack SPEC response headers
    #
    # @since 1.0.0
    # @api private
    RESPONSE_HEADERS = 1

    # Rack SPEC response body
    #
    # @since 1.0.0
    # @api private
    RESPONSE_BODY = 2

    # @since 1.0.0
    # @api private
    DEFAULT_ERROR_CODE = 500

    # Status codes that by RFC must not include a message body
    #
    # @since 0.3.2
    # @api private
    HTTP_STATUSES_WITHOUT_BODY = Set.new((100..199).to_a << 204 << 205 << 304).freeze

    # Not Found
    #
    # @since 1.0.0
    # @api private
    NOT_FOUND = 404

    # Entity headers allowed in blank body responses, according to
    # RFC 2616 - Section 10 (HTTP 1.1).
    #
    # "The response MAY include new or updated metainformation in the form
    #   of entity-headers".
    #
    # @since 0.4.0
    # @api private
    #
    # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.2.5
    # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec7.html
    ENTITY_HEADERS = {
      "Allow" => true,
      "Content-Encoding" => true,
      "Content-Language" => true,
      "Content-Location" => true,
      "Content-MD5" => true,
      "Content-Range" => true,
      "Expires" => true,
      "Last-Modified" => true,
      "extension-header" => true
    }.freeze

    # The request relative path
    #
    # @since 2.0.0
    # @api private
    PATH_INFO = ::Rack::PATH_INFO

    # The request method
    #
    # @since 0.3.2
    # @api private
    REQUEST_METHOD = ::Rack::REQUEST_METHOD

    # The Content-Length HTTP header
    #
    # @since 1.0.0
    # @api private
    CONTENT_LENGTH = ::Rack::CONTENT_LENGTH

    # The non-standard HTTP header to pass the control over when a resource
    # cannot be found by the current endpoint
    #
    # @since 1.0.0
    # @api private
    X_CASCADE = "X-Cascade"

    # HEAD request
    #
    # @since 0.3.2
    # @api private
    HEAD = ::Rack::HEAD

    # GET request
    #
    # @since 2.0.0
    # @api private
    GET = ::Rack::GET

    # TRACE request
    #
    # @since 2.0.0
    # @api private
    TRACE = ::Rack::TRACE

    # OPTIONS request
    #
    # @since 2.0.0
    # @api private
    OPTIONS = ::Rack::OPTIONS

    # The key that returns accepted mime types from the Rack env
    #
    # @since 0.1.0
    # @api private
    HTTP_ACCEPT = "HTTP_ACCEPT"

    # The default mime type for an incoming HTTP request
    #
    # @since 0.1.0
    # @api private
    DEFAULT_ACCEPT       = "*/*"

    # The default mime type that is returned in the response
    #
    # @since 0.1.0
    # @api private
    DEFAULT_CONTENT_TYPE = "application/octet-stream"

    # @since 0.2.0
    # @api private
    RACK_ERRORS = ::Rack::RACK_ERRORS

    # The HTTP header for Cache-Control
    #
    # @since 2.0.0
    # @api private
    CACHE_CONTROL = ::Rack::CACHE_CONTROL

    # @since 2.0.0
    # @api private
    IF_NONE_MATCH = "HTTP_IF_NONE_MATCH"

    # The HTTP header for ETag
    #
    # @since 2.0.0
    # @api private
    ETAG = ::Rack::ETAG

    # @since 2.0.0
    # @api private
    IF_MODIFIED_SINCE = "HTTP_IF_MODIFIED_SINCE"

    # The HTTP header for Expires
    #
    # @since 2.0.0
    # @api private
    EXPIRES = ::Rack::EXPIRES

    # The HTTP header for Last-Modified
    #
    # @since 0.3.0
    # @api private
    LAST_MODIFIED = "Last-Modified"

    # This isn't part of Rack SPEC
    #
    # Exception notifiers use <tt>rack.exception</tt> instead of
    # <tt>rack.errors</tt>, so we need to support it.
    #
    # @since 0.5.0
    # @api private
    #
    # @see Hanami::Action::Throwable::RACK_ERRORS
    # @see http://www.rubydoc.info/github/rack/rack/file/SPEC#The_Error_Stream
    # @see https://github.com/hanami/controller/issues/133
    RACK_EXCEPTION = "rack.exception"

    # The HTTP header for redirects
    #
    # @since 0.2.0
    # @api private
    LOCATION = "Location"

    # The key that returns Rack session params from the Rack env
    # Please note that this is used only when an action is unit tested.
    #
    # @since 2.0.0
    # @api private
    #
    # @example
    #   # action unit test
    #   action.call("rack.session" => { "foo" => "bar" })
    #   action.session[:foo] # => "bar"
    #
    # @api private
    RACK_SESSION = ::Rack::RACK_SESSION

    # @since 2.0.0
    # @api private
    REQUEST_ID = "hanami.request_id"

    # @since 2.0.0
    # @api private
    DEFAULT_ID_LENGTH = 16

    # The key that returns raw cookies from the Rack env
    #
    # @since 2.0.0
    # @api private
    HTTP_COOKIE = ::Rack::HTTP_COOKIE

    # The key used by Rack to set the cookies as an Hash in the env
    #
    # @since 2.0.0
    # @api private
    COOKIE_HASH_KEY = ::Rack::RACK_REQUEST_COOKIE_HASH

    # The key used by Rack to set the cookies as a String in the env
    #
    # @since 2.0.0
    # @api private
    COOKIE_STRING_KEY = ::Rack::RACK_REQUEST_COOKIE_STRING

    # The key that returns raw input from the Rack env
    #
    # @since 2.0.0
    # @api private
    RACK_INPUT = ::Rack::RACK_INPUT

    # The key that returns router params from the Rack env
    # This is a builtin integration for Hanami::Router
    #
    # @since 2.0.0
    # @api private
    ROUTER_PARAMS = "router.params"

    # Default HTTP request method for Rack env
    #
    # @since 2.0.0
    # @api private
    DEFAULT_REQUEST_METHOD = GET

    # @since 2.0.0
    # @api private
    DEFAULT_CHARSET = "utf-8"
  end
end
