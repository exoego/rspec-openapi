# frozen_string_literal: true

module Dry
  module System
    module Plugins
      module Bootsnap
        DEFAULT_OPTIONS = {
          load_path_cache: true,
          compile_cache_iseq: true,
          compile_cache_yaml: true
        }.freeze

        # @api private
        def self.extended(system)
          super

          system.use(:env)
          system.setting :bootsnap, default: DEFAULT_OPTIONS
          system.after(:configure, &:setup_bootsnap)
        end

        # @api private
        def self.dependencies
          {bootsnap: "bootsnap"}
        end

        # Set up bootsnap for faster booting
        #
        # @api public
        def setup_bootsnap
          return unless bootsnap_available?

          ::Bootsnap.setup(**config.bootsnap, cache_dir: root.join("tmp/cache").to_s)
        end

        # @api private
        def bootsnap_available?
          spec = Gem.loaded_specs["bootsnap"] or return false

          RUBY_ENGINE == "ruby" &&
            spec.match_platform(RUBY_PLATFORM) &&
            spec.required_ruby_version.satisfied_by?(Gem::Version.new(RUBY_VERSION))
        end
      end
    end
  end
end
