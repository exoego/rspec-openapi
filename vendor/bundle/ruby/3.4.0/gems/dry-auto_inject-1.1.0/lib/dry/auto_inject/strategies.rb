# frozen_string_literal: true

module Dry
  module AutoInject
    class Strategies
      extend Core::Container::Mixin

      # @api public
      def self.register_default(name, strategy)
        register name, strategy
        register :default, strategy
      end

      register :args, proc { Strategies::Args }
      register :hash, proc { Strategies::Hash }
      register_default :kwargs, proc { Strategies::Kwargs }
    end
  end
end
