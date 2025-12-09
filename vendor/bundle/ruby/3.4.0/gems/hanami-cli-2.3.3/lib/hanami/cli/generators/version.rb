# frozen_string_literal: true

module Hanami
  module CLI
    module Generators
      # @api private
      module Version
        def self.version
          return Hanami::VERSION if Hanami.const_defined?(:VERSION)

          Hanami::CLI::VERSION
        end

        def self.gem_requirement
          result = prerelease? ? prerelease_version : stable_version

          "~> #{result}"
        end

        def self.npm_package_requirement
          result = prerelease? ? prerelease_version : stable_version

          # Change "2.1.0.beta2.1" to "2.1.0-beta.2" (the only format tolerable by `npm install`)
          if prerelease?
            result = result
              .sub(/\.(alpha|beta|rc)/, '-\1')
              .sub(/(alpha|beta|rc)(\d+)(?:\.\d+)?\Z/, '\1.\2')
          end

          "^#{result}"
        end

        def self.prerelease?
          version.match?(/alpha|beta|rc/)
        end

        # @example
        #   Hanami::VERSION # => 2.3.1
        #   Hanami::CLI::Generators::Version.stable_version # => "2.3.0"
        def self.stable_version
          major_minor = version.scan(/\A\d{1,2}\.\d{1,2}/).first
          "#{major_minor}.0"
        end

        # @example
        #   Hanami::VERSION # => 2.0.0.alpha8.1
        #   Hanami::CLI::Generators::Version.prerelease_version # => "2.0.0.alpha"
        def self.prerelease_version
          version.sub(/[[[:digit:]].]*\Z/, "")
        end
      end
    end
  end
end
