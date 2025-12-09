# frozen_string_literal: true

module Dry
  module AutoInject
    class Strategies
      # @api private
      class Args < Constructor
        private

        def define_new
          class_mod.class_exec(container, dependency_map) do |container, dependency_map|
            deps_with_indices = dependency_map.to_h.values.map.with_index

            define_method :new do |*args|
              deps = deps_with_indices.map do |identifier, i|
                args[i] || container[identifier]
              end

              super(*deps, *args.drop(deps.size))
            end
          end
        end

        def define_initialize(klass)
          super_parameters = MethodParameters.of(klass, :initialize).each do |ps|
            # Look upwards past `def foo(*)` methods until we get an explicit list of parameters
            break ps unless ps.pass_through?
          end

          if super_parameters.empty?
            define_initialize_with_params
          else
            define_initialize_with_splat(super_parameters)
          end
        end

        def define_initialize_with_params
          initialize_args = dependency_map.names.join(", ")

          assignment = dependency_map.names.map { "@#{_1} = #{_1}" }.join("\n")

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(#{initialize_args})  # def initialize(dep)
              #{assignment}                     #   @dep = dep
              super()                           #   super()
            end                                 # end
          RUBY
        end

        def define_initialize_with_splat(super_parameters)
          super_pass =
            if super_parameters.splat?
              "*args"
            else
              "*args.take(#{super_parameters.length})"
            end

          assignments = dependency_map.names.map.with_index do |name, idx|
            "@#{name} = args[#{idx}]"
          end
          body = assignments.join("\n")

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(*args)    # def initialize(*args)
              #{body}                #   @dep = args[0]
              super(#{super_pass})   #   super(*args)
            end                      # end
          RUBY
        end
      end
    end
  end
end
