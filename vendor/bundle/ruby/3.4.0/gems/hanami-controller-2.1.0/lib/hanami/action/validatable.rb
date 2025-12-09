# frozen_string_literal: true

require_relative "params"

module Hanami
  class Action
    # Support for validating params when calling actions.
    #
    # Included only when hanami-validations (and its dependencies) are bundled.
    #
    # @api private
    # @since 0.1.0
    module Validatable
      # Defines the class name for anonymous params
      #
      # @api private
      # @since 0.3.0
      PARAMS_CLASS_NAME = "Params"

      # @api private
      # @since 0.1.0
      def self.included(base)
        base.extend ClassMethods
      end

      # Validatable API class methods
      #
      # @since 0.1.0
      # @api private
      module ClassMethods
        # Whitelist valid parameters to be passed to Hanami::Action#call.
        #
        # This feature isn't mandatory, but higly recommended for security
        # reasons.
        #
        # Because params come into your application from untrusted sources, it's
        # a good practice to filter only the wanted keys that serve for your
        # specific use case.
        #
        # Once whitelisted, the params are available as an Hash with symbols
        # as keys.
        #
        # It accepts an anonymous block where all the params can be listed.
        # It internally creates an inner class which inherits from
        # Hanami::Action::Params.
        #
        # Alternatively, it accepts an concrete class that should inherit from
        # Hanami::Action::Params.
        #
        # @param klass [Class,nil] a Hanami::Action::Params subclass
        # @param blk [Proc] a block which defines the whitelisted params
        #
        # @return void
        #
        # @see Hanami::Action::Params
        # @see https://guides.hanamirb.org//validations/overview
        #
        # @example Anonymous Block
        #   require "hanami/controller"
        #
        #   class Signup < Hanami::Action
        #     params do
        #       required(:first_name)
        #       required(:last_name)
        #       required(:email)
        #     end
        #
        #     def handle(req, *)
        #       puts req.params.class            # => Signup::Params
        #       puts req.params.class.superclass # => Hanami::Action::Params
        #
        #       puts req.params[:first_name]     # => "Luca"
        #       puts req.params[:admin]          # => nil
        #     end
        #   end
        #
        # @example Concrete class
        #   require "hanami/controller"
        #
        #   class SignupParams < Hanami::Action::Params
        #     required(:first_name)
        #     required(:last_name)
        #     required(:email)
        #   end
        #
        #   class Signup < Hanami::Action
        #     params SignupParams
        #
        #     def handle(req, *)
        #       puts req.params.class            # => SignupParams
        #       puts req.params.class.superclass # => Hanami::Action::Params
        #
        #       req.params[:first_name]          # => "Luca"
        #       req.params[:admin]               # => nil
        #     end
        #   end
        #
        # @since 0.3.0
        # @api public
        def params(klass = nil, &blk)
          if klass.nil?
            klass = const_set(PARAMS_CLASS_NAME, Class.new(Params))
            klass.class_eval { params(&blk) }
          end

          @params_class = klass
        end
      end
    end
  end
end
