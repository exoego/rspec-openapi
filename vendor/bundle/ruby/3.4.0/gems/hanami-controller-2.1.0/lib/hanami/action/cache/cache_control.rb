# frozen_string_literal: true

module Hanami
  class Action
    module Cache
      # Module with Cache-Control logic
      #
      # @since 0.3.0
      # @api private
      module CacheControl
        # @since 0.3.0
        # @api private
        def self.included(base)
          base.class_eval do
            extend ClassMethods
            @cache_control_directives = nil
          end
        end

        # @since 0.3.0
        # @api private
        module ClassMethods
          # @since 0.3.0
          # @api private
          def cache_control(*values)
            @cache_control_directives ||= Directives.new(*values)
          end

          # @since 0.3.0
          # @api private
          def cache_control_directives
            @cache_control_directives || Object.new.tap do |null_object|
              def null_object.headers
                {}
              end
            end
          end
        end

        # Finalize the response including default cache headers into the response
        #
        # @since 0.3.0
        # @api private
        #
        # @see Hanami::Action#finish
        def finish(_, res, _)
          unless res.headers.include?(Action::CACHE_CONTROL)
            res.headers.merge!(self.class.cache_control_directives.headers)
          end

          super
        end

        # Class which stores CacheControl values
        #
        # @since 0.3.0
        # @api private
        class Directives
          # @since 2.0.0
          # @api private
          SEPARATOR = ", "
          private_constant :SEPARATOR

          # @since 0.3.0
          # @api private
          def initialize(*values)
            @directives = Hanami::Action::Cache::Directives.new(*values)
          end

          # @since 0.3.0
          # @api private
          def headers
            if @directives.any?
              {Action::CACHE_CONTROL => @directives.join(SEPARATOR)}
            else
              {}
            end
          end
        end
      end
    end
  end
end
