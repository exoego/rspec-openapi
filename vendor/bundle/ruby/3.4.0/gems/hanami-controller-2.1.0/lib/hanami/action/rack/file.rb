# frozen_string_literal: true

require "rack/file"

module Hanami
  class Action
    # Rack extensions for actions.
    #
    # @api private
    # @since 0.4.3
    module Rack
      # File to be sent
      #
      # @see Hanami::Action::Response#send_file
      #
      # @since 0.4.3
      # @api private
      class File
        # @param path [String,Pathname] file path
        #
        # @since 0.4.3
        # @api private
        def initialize(path, root)
          @file = ::Rack::File.new(root.to_s)
          @path = path.to_s
        end

        # @since 0.4.3
        # @api private
        def call(env)
          env = env.dup
          env[Action::PATH_INFO] = @path

          @file.get(env)
        rescue Errno::ENOENT
          [Action::NOT_FOUND, {}, nil]
        end
      end
    end
  end
end
