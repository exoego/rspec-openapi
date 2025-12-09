# frozen_string_literal: true

module Dry
  module AutoInject
    DuplicateDependencyError = ::Class.new(::StandardError)
    DependencyNameInvalid = ::Class.new(::StandardError)

    VALID_NAME = /([a-z_][a-zA-Z_0-9]*)$/

    class DependencyMap
      def initialize(*dependencies)
        @map = {}

        dependencies = dependencies.dup
        aliases = dependencies.last.is_a?(::Hash) ? dependencies.pop : {}

        dependencies.each do |identifier|
          name = name_for(identifier)
          add_dependency(name, identifier)
        end

        aliases.each do |name, identifier|
          add_dependency(name, identifier)
        end
      end

      def inspect = @map.inspect

      def names
        @names ||= @map.keys
      end

      def to_h = @map.dup
      alias_method :to_hash, :to_h

      private

      def name_for(identifier)
        matched = VALID_NAME.match(identifier.to_s)
        unless matched
          raise DependencyNameInvalid,
                "name +#{identifier}+ is not a valid Ruby identifier"
        end

        matched[0]
      end

      def add_dependency(name, identifier)
        name = name.to_sym
        raise DuplicateDependencyError, "name +#{name}+ is already used" if @map.key?(name)

        @map[name] = identifier
      end
    end
  end
end
