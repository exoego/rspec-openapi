# frozen_string_literal: true

module Dry
  module System
    class Provider
      # A provider's source provides the specific behavior for a given provider to serve
      # its purpose.
      #
      # Sources should be subclasses of `Dry::System::Source::Provider`, with instance
      # methods for each lifecycle step providing their behavior: {#prepare}, {#start},
      # and {#stop}.
      #
      # Inside each of these methods, you should create and configure your provider's
      # objects as required, and then {#register} them with the {#provider_container}.
      # When the provider's lifecycle steps are run (via {Dry::System::Provider}), these
      # registered components will be merged into the target container.
      #
      # You can prepare a provider's source in two ways:
      #
      # 1. Passing a bock when registering the provider, which is then evaluated via
      #    {Dry::System::Provider::SourceDSL} to prepare the provider subclass. This
      #    approach is easiest for simple providers.
      # 2. Manually creare your own subclass of {Dry::System::Provider} and implement your
      #    own instance methods for the lifecycle steps (you should not implement your own
      #    `#initialize`). This approach may be useful for more complex providers.
      #
      # @see Dry::System::Container.register_provider
      # @see Dry::System.register_provider_source
      # @see Dry::System::Source::ProviderDSL
      #
      # @api public
      class Source
        class << self
          # Returns a new Dry::System::Provider::Source subclass with its behavior supplied by the
          # given block, which is evaluated using Dry::System::Provider::SourceDSL.
          #
          # @see Dry::System::Provider::SourceDSL
          #
          # @api private
          def for(name:, group: nil, superclass: nil, &block)
            superclass ||= self

            ::Class.new(superclass) { |klass|
              klass.source_name name
              klass.source_group group

              name_with_group = group ? "#{group}->#{name}" : name
              klass.instance_eval(<<~RUBY, __FILE__, __LINE__ + 1)
                def name                                   # def name
                  "#{superclass.name}[#{name_with_group}]" #   "CustomSource[custom]"
                end                                        # end
              RUBY

              SourceDSL.evaluate(klass, &block) if block_given?
            }
          end

          def inherited(subclass)
            super

            # Include Dry::Configurable only when first subclassing to ensure that
            # distinct Source subclasses do not share settings.
            #
            # The superclass check here allows deeper Source class hierarchies to be
            # created without running into a Dry::Configurable::AlreadyIncluded error.
            if subclass.superclass == Source
              subclass.include Dry::Configurable
            end
          end

          # @api private
          def to_s
            "#<#{name}>"
          end

          # @api private
          def inspect
            to_s
          end
        end

        CALLBACK_MAP = Hash.new { |h, k| h[k] = [] }.freeze

        extend Dry::Core::ClassAttributes

        defines :source_name, :source_group

        # @api private
        attr_reader :callbacks

        # Returns the provider's own container for the provider.
        #
        # This container is namespaced based on the provider's `namespace:` configuration.
        #
        # Registered components in this container will be merged into the target container
        # after the `prepare` and `start` lifecycle steps.
        #
        # @return [Dry::Container]
        #
        # @see #target_container
        # @see Dry::System::Provider
        #
        # @api public
        attr_reader :provider_container
        alias_method :container, :provider_container

        # Returns the target container for the provider.
        #
        # This is the container with which the provider is registered (via
        # {Dry::System::Container.register_provider}).
        #
        # Registered components from the provider's container will be merged into this
        # container after the `prepare` and `start` lifecycle steps.
        #
        # @return [Dry::System::Container]
        #
        # @see #provider_container
        # @see Dry::System::Provider
        #
        # @api public
        attr_reader :target_container

        # @see #target_container
        # @api public
        def target = target_container

        # @api private
        def initialize(provider_container:, target_container:, &)
          super()
          @callbacks = {before: CALLBACK_MAP.dup, after: CALLBACK_MAP.dup}
          @provider_container = provider_container
          @target_container = target_container
          instance_exec(&) if block_given?
        end

        # Returns a string containing a human-readable representation of the provider.
        #
        # @return [String]
        #
        # @api private
        def inspect
          ivars = instance_variables.map { |ivar|
            "#{ivar}=#{instance_variable_get(ivar).inspect}"
          }.join(" ")

          "#<#{self.class.name} #{ivars}>"
        end

        # Runs the behavior for the "prepare" lifecycle step.
        #
        # This should be implemented by your source subclass or specified by
        # `SourceDSL#prepare` when registering a provider using a block.
        #
        # @return [void]
        #
        # @see SourceDSL#prepare
        #
        # @api public
        def prepare; end

        # Runs the behavior for the "start" lifecycle step.
        #
        # This should be implemented by your source subclass or specified by
        # `SourceDSL#start` when registering a provider using a block.
        #
        # You can presume that {#prepare} has already run by the time this method is
        # called.
        #
        # @return [void]
        #
        # @see SourceDSL#start
        #
        # @api public
        def start; end

        # Runs the behavior for the "stop" lifecycle step.
        #
        # This should be implemented by your source subclass or specified by
        # `SourceDSL#stop` when registering a provider using a block.
        #
        # You can presume that {#prepare} and {#start} have already run by the time this
        # method is called.
        #
        # @return [void]
        #
        # @see SourceDSL#stop
        #
        # @api public
        def stop; end

        # Registers a "before" callback for the given lifecycle step.
        #
        # The given block will be run before the lifecycle step method is run. The block
        # will be evaluated in the context of the instance of this source.
        #
        # @param step_name [Symbol]
        # @param block [Proc] the callback block
        #
        # @return [self]
        #
        # @see #after
        #
        # @api public
        def before(step_name, &block)
          callbacks[:before][step_name] << block
          self
        end

        # Registers an "after" callback for the given lifecycle step.
        #
        # The given block will be run after the lifecycle step method is run. The block
        # will be evaluated in the context of the instance of this source.
        #
        # @param step_name [Symbol]
        # @param block [Proc] the callback block
        #
        # @return [self]
        #
        # @see #before
        #
        # @api public
        def after(step_name, &block)
          callbacks[:after][step_name] << block
          self
        end

        # @api private
        def run_callback(hook, step)
          callbacks[hook][step].each do |callback|
            instance_eval(&callback)
          end
        end

        private

        # Registers a component in the provider container.
        #
        # When the provider's lifecycle steps are run (via {Dry::System::Provider}), these
        # registered components will be merged into the target container.
        #
        # @return [Dry::Container] the provider container
        #
        # @api public
        def register(...)
          provider_container.register(...)
        end

        # Resolves a previously registered component from the provider container.
        #
        # @param key [String] the key for the component to resolve
        #
        # @return [Object] the previously registered component
        #
        # @api public
        def resolve(key)
          provider_container.resolve(key)
        end

        # @api private
        def run_step_block(step_name)
          step_block = self.class.step_blocks[step_name]
          instance_eval(&step_block) if step_block
        end

        # @api private
        def method_missing(name, *args, &)
          if container.key?(name)
            container[name]
          else
            super
          end
        end

        # @api private
        def respond_to_missing?(name, include_all = false)
          container.key?(name) || super
        end
      end
    end
  end
end
