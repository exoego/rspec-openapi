# frozen_string_literal: true

module Hanami
  class Action
    module Cache
      # Cache-Control directives which have values
      #
      # @since 0.3.0
      # @api private
      VALUE_DIRECTIVES      = %i[max_age s_maxage min_fresh max_stale].freeze

      # Cache-Control directives which are implicitly true
      #
      # @since 0.3.0
      # @api private
      NON_VALUE_DIRECTIVES  = %i[public private no_cache no_store no_transform must_revalidate proxy_revalidate].freeze

      # Class representing value directives
      #
      # ex: max-age=600
      #
      # @since 0.3.0
      # @api private
      class ValueDirective
        # @since 0.3.0
        # @api private
        attr_reader :name

        # @since 0.3.0
        # @api private
        def initialize(name, value)
          @name, @value = name, value
        end

        # @since 0.3.0
        # @api private
        def to_str
          "#{@name.to_s.tr('_', '-')}=#{@value.to_i}"
        end

        # @since 0.3.0
        # @api private
        def valid?
          VALUE_DIRECTIVES.include? @name
        end
      end

      # Class representing non value directives
      #
      # ex: no-cache
      #
      # @since 0.3.0
      # @api private
      class NonValueDirective
        # @since 0.3.0
        # @api private
        attr_reader :name

        # @since 0.3.0
        # @api private
        def initialize(name)
          @name = name
        end

        # @since 0.3.0
        # @api private
        def to_str
          @name.to_s.tr("_", "-")
        end

        # @since 0.3.0
        # @api private
        def valid?
          NON_VALUE_DIRECTIVES.include? @name
        end
      end

      # Collection of value and non value directives
      #
      # @since 0.3.0
      # @api private
      class Directives
        include Enumerable

        # @since 0.3.0
        # @api private
        def initialize(*values)
          @directives = []
          values.each do |directive_key|
            if directive_key.is_a? Hash
              directive_key.each { |name, value| self << ValueDirective.new(name, value) }
            else
              self << NonValueDirective.new(directive_key)
            end
          end
        end

        # @since 0.3.0
        # @api private
        def each(&block)
          @directives.each(&block)
        end

        # @since 0.3.0
        # @api private
        def <<(directive)
          @directives << directive if directive.valid?
        end

        # @since 0.3.0
        # @api private
        def values
          @directives.delete_if do |directive|
            directive.name == :public && @directives.map(&:name).include?(:private)
          end
        end

        # @since 0.3.0
        # @api private
        def join(separator)
          values.join(separator)
        end
      end
    end
  end
end
