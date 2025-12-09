# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    module Plugins
      # @api private
      class Zeitwerk < Module
        # @api private
        def self.dependencies
          [
            "dry/system/loader/autoloading",
            "dry/system/plugins/zeitwerk/compat_inflector",
            {"zeitwerk" => "zeitwerk"}
          ]
        end

        # @api private
        attr_reader :loader, :run_setup, :eager_load, :debug

        # @api private
        def initialize(loader: nil, run_setup: true, eager_load: nil, debug: false)
          @loader = loader || ::Zeitwerk::Loader.new
          @run_setup = run_setup
          @eager_load = eager_load
          @debug = debug
          super()
        end

        # @api private
        def extended(system)
          system.setting :autoloader, reader: true

          system.config.autoloader = loader
          system.config.component_dirs.loader = Dry::System::Loader::Autoloading
          system.config.component_dirs.add_to_load_path = false

          system.after(:configure, &method(:setup_autoloader))

          super
        end

        private

        def setup_autoloader(system)
          configure_loader(system.autoloader, system)

          push_component_dirs_to_loader(system, system.autoloader)

          system.autoloader.setup if run_setup

          system.after(:finalize) { system.autoloader.eager_load } if eager_load?(system)

          system
        end

        # Build a zeitwerk loader with the configured component directories
        #
        # @return [Zeitwerk::Loader]
        def configure_loader(loader, system)
          loader.tag = system.config.name || system.name unless loader.tag
          loader.inflector = CompatInflector.new(system.config)
          loader.logger = method(:puts) if debug
        end

        # Add component dirs to the zeitwerk loader
        #
        # @return [Zeitwerk::Loader]
        def push_component_dirs_to_loader(system, loader)
          system.config.component_dirs.each do |dir|
            dir.namespaces.each do |ns|
              loader.push_dir(
                system.root.join(dir.path, ns.path.to_s),
                namespace: module_for_namespace(ns, system.config.inflector)
              )
            end
          end

          loader
        end

        def module_for_namespace(namespace, inflector)
          return Object unless namespace.const

          begin
            inflector.constantize(inflector.camelize(namespace.const))
          rescue NameError
            namespace.const.split(PATH_SEPARATOR).reduce(Object) { |parent_mod, mod_path|
              get_or_define_module(parent_mod, inflector.camelize(mod_path))
            }
          end
        end

        def get_or_define_module(parent_mod, name)
          parent_mod.const_get(name)
        rescue NameError
          parent_mod.const_set(name, Module.new)
        end

        def eager_load?(system)
          return eager_load unless eager_load.nil?

          system.config.respond_to?(:env) && system.config.env == :production
        end
      end
    end
  end
end
