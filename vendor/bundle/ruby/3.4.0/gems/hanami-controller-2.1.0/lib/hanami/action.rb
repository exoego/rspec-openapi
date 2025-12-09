# frozen_string_literal: true

require "dry/configurable"
require "hanami/utils"
require "hanami/utils/callbacks"
require "hanami/utils/kernel"
require "hanami/utils/string"
require "rack"
require "rack/utils"
require "zeitwerk"

require_relative "action/constants"
require_relative "action/errors"

module Hanami
  # An HTTP endpoint
  #
  # @since 0.1.0
  #
  # @example
  #   require "hanami/controller"
  #
  #   class Show < Hanami::Action
  #     def handle(req, res)
  #       # ...
  #     end
  #   end
  #
  # @api public
  class Action
    # @since 2.0.0
    # @api private
    def self.gem_loader
      @gem_loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "hanami-controller"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/hanami-controller.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/hanami-controller.rb",
          "#{root}/hanami/controller/version.rb",
          "#{root}/hanami/action/{constants,errors,params,validatable}.rb"
        )
        loader.inflector.inflect("csrf_protection" => "CSRFProtection")
      end
    end

    gem_loader.setup

    # Make conditional requires after Zeitwerk setup so any internal autoloading works as expected
    begin
      require "hanami/validations"
      require_relative "action/validatable"
    rescue LoadError # rubocop:disable Lint/SuppressedException
    end

    extend Dry::Configurable(config_class: Config)

    # See {Config} for individual setting accessor API docs
    setting :handled_exceptions, default: {}
    setting :formats, default: Config::Formats.new, mutable: true
    setting :default_charset
    setting :default_headers, default: {}, constructor: -> (headers) { headers.compact }
    setting :cookies, default: {}, constructor: -> (cookie_options) {
      # Call `to_h` here to permit `ApplicationConfiguration::Cookies` object to be
      # provided when application actions are configured
      cookie_options.to_h.compact
    }
    setting :root_directory, constructor: -> (dir) {
      Pathname(File.expand_path(dir || Dir.pwd))
    }
    setting :public_directory, default: Config::DEFAULT_PUBLIC_DIRECTORY
    setting :before_callbacks, default: Utils::Callbacks::Chain.new, mutable: true
    setting :after_callbacks, default: Utils::Callbacks::Chain.new, mutable: true

    # @!scope class

    # @!method config
    #   Returns the action's config. Use this to configure your action.
    #
    #   @example Access inside class body
    #     class Show < Hanami::Action
    #       config.format :json
    #     end
    #
    #   @return [Config]
    #
    #   @api public
    #   @since 2.0.0

    # @!scope instance

    # Override Ruby's hook for modules.
    # It includes basic Hanami::Action modules to the given class.
    #
    # @param subclass [Class] the target action
    #
    # @since 0.1.0
    # @api private
    def self.inherited(subclass)
      super

      if subclass.superclass == Action
        subclass.class_eval do
          include Validatable if defined?(Validatable)
        end
      end

      if instance_variable_defined?(:@params_class)
        subclass.instance_variable_set(:@params_class, @params_class)
      end
    end

    # Returns the class which defines the params
    #
    # Returns the class which has been provided to define the
    # params. By default this will be Hanami::Action::Params.
    #
    # @return [Class] A params class (when whitelisted) or
    #   Hanami::Action::Params
    #
    # @api private
    # @since 0.7.0
    def self.params_class
      @params_class || BaseParams
    end

    # Placeholder implementation for params class method
    #
    # Raises a developer friendly error to include `hanami/validations`.
    #
    # @raise [NoMethodError]
    #
    # @api public
    # @since 2.0.0
    def self.params(_klass = nil)
      raise NoMethodError,
            "To use `params`, please add 'hanami/validations' gem to your Gemfile"
    end

    # @overload self.append_before(*callbacks, &block)
    #   Define a callback for an Action.
    #   The callback will be executed **before** the action is called, in the
    #   order they are added.
    #
    #   @param callbacks [Symbol, Array<Symbol>] a single or multiple symbol(s)
    #     each of them is representing a name of a method available in the
    #     context of the Action.
    #
    #   @param blk [Proc] an anonymous function to be executed
    #
    #   @return [void]
    #
    #   @since 0.3.2
    #
    #   @see Hanami::Action::Callbacks::ClassMethods#append_after
    #
    #   @example Method names (symbols)
    #     require "hanami/controller"
    #
    #     class Show < Hanami::Action
    #       before :authenticate, :set_article
    #
    #       def handle(req, res)
    #       end
    #
    #       private
    #       def authenticate
    #         # ...
    #       end
    #
    #       # `params` in the method signature is optional
    #       def set_article(params)
    #         @article = Article.find params[:id]
    #       end
    #     end
    #
    #     # The order of execution will be:
    #     #
    #     # 1. #authenticate
    #     # 2. #set_article
    #     # 3. #call
    #
    #   @example Anonymous functions (Procs)
    #     require "hanami/controller"
    #
    #     class Show < Hanami::Action
    #       before { ... } # 1 do some authentication stuff
    #       before {|req, res| @article = Article.find params[:id] } # 2
    #
    #       def handle(req, res)
    #       end
    #     end
    #
    #     # The order of execution will be:
    #     #
    #     # 1. authentication
    #     # 2. set the article
    #     # 3. `#handle`
    def self.append_before(...)
      config.before_callbacks.append(...)
    end

    class << self
      # @since 0.1.0
      alias_method :before, :append_before
    end

    # @overload self.append_after(*callbacks, &block)
    #   Define a callback for an Action.
    #   The callback will be executed **after** the action is called, in the
    #   order they are added.
    #
    #   @param callbacks [Symbol, Array<Symbol>] a single or multiple symbol(s)
    #     each of them is representing a name of a method available in the
    #     context of the Action.
    #
    #   @param blk [Proc] an anonymous function to be executed
    #
    #   @return [void]
    #
    #   @since 0.3.2
    #
    #   @see Hanami::Action::Callbacks::ClassMethods#append_before
    def self.append_after(...)
      config.after_callbacks.append(...)
    end

    class << self
      # @since 0.1.0
      alias_method :after, :append_after
    end

    # @overload self.prepend_before(*callbacks, &block)
    #   Define a callback for an Action.
    #   The callback will be executed **before** the action is called.
    #   It will add the callback at the beginning of the callbacks' chain.
    #
    #   @param callbacks [Symbol, Array<Symbol>] a single or multiple symbol(s)
    #     each of them is representing a name of a method available in the
    #     context of the Action.
    #
    #   @param blk [Proc] an anonymous function to be executed
    #
    #   @return [void]
    #
    #   @since 0.3.2
    #
    #   @see Hanami::Action::Callbacks::ClassMethods#prepend_after
    def self.prepend_before(...)
      config.before_callbacks.prepend(...)
    end

    # @overload self.prepend_after(*callbacks, &block)
    #   Define a callback for an Action.
    #   The callback will be executed **after** the action is called.
    #   It will add the callback at the beginning of the callbacks' chain.
    #
    #   @param callbacks [Symbol, Array<Symbol>] a single or multiple symbol(s)
    #     each of them is representing a name of a method available in the
    #     context of the Action.
    #
    #   @param blk [Proc] an anonymous function to be executed
    #
    #   @return [void]
    #
    #   @since 0.3.2
    #
    #   @see Hanami::Action::Callbacks::ClassMethods#prepend_before
    def self.prepend_after(...)
      config.after_callbacks.prepend(...)
    end

    # @see Config#format
    #
    # @since 2.0.0
    # @api public
    def self.format(...)
      config.format(...)
    end

    # @see Config#handle_exception
    #
    # @since 2.0.0
    # @api public
    def self.handle_exception(...)
      config.handle_exception(...)
    end

    # Returns a new action
    #
    # @since 2.0.0
    # @api public
    def initialize(config: self.class.config)
      @config = config
      freeze
    end

    # Implements the Rack/Hanami::Action protocol
    #
    # @since 0.1.0
    # @api private
    def call(env)
      request  = nil
      response = nil

      halted = catch :halt do
        params   = self.class.params_class.new(env)
        request  = build_request(
          env: env,
          params: params,
          session_enabled: session_enabled?
        )
        response = build_response(
          request: request,
          config: config,
          content_type: Mime.response_content_type_with_charset(request, config),
          env: env,
          headers: config.default_headers,
          session_enabled: session_enabled?
        )

        enforce_accepted_mime_types(request)

        _run_before_callbacks(request, response)
        handle(request, response)
        _run_after_callbacks(request, response)
      rescue StandardError => exception
        _handle_exception(request, response, exception)
      end

      finish(request, response, halted)
    end

    protected

    # Hook for subclasses to apply behavior as part of action invocation
    #
    # @param request [Hanami::Action::Request]
    # @param response [Hanami::Action::Response]
    #
    # @since 2.0.0
    # @api public
    def handle(request, response)
    end

    # Halt the action execution with the given HTTP status code and message.
    #
    # When used, the execution of a callback or of an action is interrupted
    # and the control returns to the framework, that decides how to handle
    # the event.
    #
    # If a message is provided, it sets the response body with the message.
    # Otherwise, it sets the response body with the default message associated
    # to the code (eg 404 will set `"Not Found"`).
    #
    # @param status [Fixnum] a valid HTTP status code
    # @param body [String] the response body
    #
    # @raise [StandardError] if the code isn't valid
    #
    # @since 0.2.0
    #
    # @see Hanami::Action::Throwable#handle_exception
    # @see Hanami::Http::Status:ALL
    #
    # @example Basic usage
    #   require "hanami/controller"
    #
    #   class Show < Hanami::Action
    #     def handle(*)
    #       halt 404
    #     end
    #   end
    #
    #   # => [404, {}, ["Not Found"]]
    #
    # @example Custom message
    #   require "hanami/controller"
    #
    #   class Show < Hanami::Action
    #     def handle(*)
    #       halt 404, "This is not the droid you're looking for."
    #     end
    #   end
    #
    #   # => [404, {}, ["This is not the droid you're looking for."]]
    def halt(status, body = nil)
      Halt.call(status, body)
    end

    # @since 0.3.2
    # @api private
    def _requires_no_body?(res)
      HTTP_STATUSES_WITHOUT_BODY.include?(res.status)
    end

    # @since 2.0.0
    # @api private
    alias_method :_requires_empty_headers?, :_requires_no_body?

    private

    # @since 2.0.0
    # @api private
    attr_reader :config

    # @since 2.0.0
    # @api private
    def enforce_accepted_mime_types(request)
      return if config.formats.empty?

      Mime.enforce_accept(request, config) { return halt 406 }
      Mime.enforce_content_type(request, config) { return halt 415 }
    end

    # @since 2.0.0
    # @api private
    def exception_handler(exception)
      config.handled_exceptions.each do |exception_class, handler|
        return handler if exception.is_a?(exception_class)
      end

      nil
    end

    # @see Session#session_enabled?
    # @since 2.0.0
    # @api private
    def session_enabled?
      false
    end

    # Hook to be overridden by `Hanami::Extensions::Action` for integrated actions
    #
    # @since 2.0.0
    # @api private
    def build_request(**options)
      Request.new(**options)
    end

    # Hook to be overridden by `Hanami::Extensions::Action` for integrated actions
    #
    # @since 2.0.0
    # @api private
    def build_response(**options)
      Response.new(**options)
    end

    # @since 0.2.0
    # @api private
    def _reference_in_rack_errors(req, exception)
      req.env[RACK_EXCEPTION] = exception

      if errors = req.env[RACK_ERRORS]
        errors.write(_dump_exception(exception))
        errors.flush
      end
    end

    # @since 0.2.0
    # @api private
    def _dump_exception(exception)
      [[exception.class, exception.message].compact.join(": "), *exception.backtrace].join("\n\t")
    end

    # @since 0.1.0
    # @api private
    def _handle_exception(req, res, exception)
      handler = exception_handler(exception)

      if handler.nil?
        _reference_in_rack_errors(req, exception)
        raise exception
      end

      instance_exec(
        req,
        res,
        exception,
        &_exception_handler(handler)
      )

      nil
    end

    # @since 0.3.0
    # @api private
    def _exception_handler(handler)
      if respond_to?(handler.to_s, true)
        method(handler)
      else
        ->(*) { halt handler }
      end
    end

    # @since 0.1.0
    # @api private
    def _run_before_callbacks(*args)
      config.before_callbacks.run(self, *args)
      nil
    end

    # @since 0.1.0
    # @api private
    def _run_after_callbacks(*args)
      config.after_callbacks.run(self, *args)
      nil
    end

    # According to RFC 2616, when a response MUST have an empty body, it only
    # allows Entity Headers.
    #
    # For instance, a <tt>204</tt> doesn't allow <tt>Content-Type</tt> or any
    # other custom header.
    #
    # This restriction is enforced by <tt>Hanami::Action#_requires_no_body?</tt>.
    #
    # However, there are cases that demand to bypass this rule to set meta
    # informations via headers.
    #
    # An example is a <tt>DELETE</tt> request for a JSON API application.
    # It returns a <tt>204</tt> but still wants to specify the rate limit
    # quota via <tt>X-Rate-Limit</tt>.
    #
    # @since 0.5.0
    #
    # @see Hanami::Action#_requires_no_body?
    #
    # @example
    #   require "hanami/controller"
    #
    #   module Books
    #     class Destroy < Hanami::Action
    #       def handle(*, res)
    #         # ...
    #         res.headers.merge!(
    #           "Last-Modified" => "Fri, 27 Nov 2015 13:32:36 GMT",
    #           "X-Rate-Limit"  => "4000",
    #           "Content-Type"  => "application/json",
    #           "X-No-Pass"     => "true"
    #         )
    #
    #         res.status = 204
    #       end
    #
    #       private
    #
    #       def keep_response_header?(header)
    #         super || header == "X-Rate-Limit"
    #       end
    #     end
    #   end
    #
    #   # Only the following headers will be sent:
    #   #  * Last-Modified - because we used `super' in the method that respects the HTTP RFC
    #   #  * X-Rate-Limit  - because we explicitely allow it
    #
    #   # Both Content-Type and X-No-Pass are removed because they're not allowed
    def keep_response_header?(header)
      ENTITY_HEADERS.include?(header)
    end

    # @since 2.0.0
    # @api private
    def _empty_headers(res)
      res.headers.select! { |header, _| keep_response_header?(header) }
    end

    # @since 2.0.0
    # @api private
    def _empty_body(res)
      res.body = Response::EMPTY_BODY
    end

    # Finalize the response
    #
    # Prepare the data before the response will be returned to the webserver
    #
    # @since 0.1.0
    # @api private
    # @abstract
    #
    # @see Hanami::Action::Session#finish
    # @see Hanami::Action::Cookies#finish
    # @see Hanami::Action::Cache#finish
    def finish(req, res, halted)
      res.status, res.body = *halted unless halted.nil?

      _empty_headers(res) if _requires_empty_headers?(res)
      _empty_body(res) if res.head?

      res.set_format(Action::Mime.detect_format(res.content_type, config))
      res[:params] = req.params
      res[:format] = res.format
      res
    end
  end
end
