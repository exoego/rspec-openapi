# frozen_string_literal: true

module Hanami
  class Action
    module Cache
      # Module with Expires logic
      #
      # @since 0.3.0
      # @api private
      module Expires
        # @since 0.3.0
        # @api private
        def self.included(base)
          base.class_eval do
            extend ClassMethods
            @expires_directives = nil
          end
        end

        # @since 0.3.0
        # @api private
        module ClassMethods
          # @since 0.3.0
          # @api private
          def expires(amount, *values)
            @expires_directives ||= Directives.new(amount, *values)
          end

          # @since 0.3.0
          # @api private
          def expires_directives
            @expires_directives || Object.new.tap do |null_object|
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
          unless res.headers.include?(Action::EXPIRES)
            res.headers.merge!(self.class.expires_directives.headers)
          end

          super
        end

        # Class which stores Expires directives
        #
        # @since 0.3.0
        # @api private
        class Directives
          # @since 0.3.0
          # @api private
          def initialize(amount, *values)
            @amount = amount
            @cache_control = Hanami::Action::Cache::CacheControl::Directives.new(*(values << {max_age: amount}))
          end

          # @since 0.3.0
          # @api private
          def headers
            {Action::EXPIRES => time.httpdate}.merge(@cache_control.headers)
          end

          private

          # @since 0.3.0
          # @api private
          def time
            Time.now + @amount.to_i
          end
        end
      end
    end
  end
end
