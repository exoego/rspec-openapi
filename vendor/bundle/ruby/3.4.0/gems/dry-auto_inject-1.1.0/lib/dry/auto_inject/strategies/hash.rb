# frozen_string_literal: true

module Dry
  module AutoInject
    class Strategies
      # @api private
      class Hash < Constructor
        private

        def define_new
          class_mod.class_exec(container, dependency_map) do |container, dependency_map|
            deps_map = dependency_map.to_h

            define_method :new do |options = {}|
              deps = deps_map.transform_values do |identifier|
                options[identifier] || container[identifier]
              end

              super({**deps, **options})
            end
          end
        end

        def define_initialize(klass)
          super_params = MethodParameters.of(klass, :initialize).first
          super_pass = super_params.empty? ? "" : "options"
          assignments = dependency_map.names.map do |name|
            <<~RUBY
              if options.key?(:#{name}) || !instance_variable_defined?(:'@#{name}')
                @#{name} = options[:#{name}]
              end
            RUBY
          end
          body = assignments.join("\n")

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(options) # def initialize(options)
                                    #   if options.key?(:dep) || !instance_variable_defined?(:@dep)
              #{body}               #     @dep = options[:dep]
                                    #   end
              super(#{super_pass})  #   super(options)
            end                     # end
          RUBY
        end
      end
    end
  end
end
