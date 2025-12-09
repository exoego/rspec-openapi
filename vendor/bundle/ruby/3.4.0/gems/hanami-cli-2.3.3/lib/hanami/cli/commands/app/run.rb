# frozen_string_literal: true

require "hanami"
require_relative "../../errors"

module Hanami
  module CLI
    module Commands
      module App
        # Run a given code or file in the context of the application
        #
        # This command is useful for running scripts that need to load the application environment.
        # You can pass a Ruby file to be executed, or you can run an interactive Ruby shell (IRB)
        # with the application environment loaded.
        #
        # Examples:
        #
        # $ bundle exec hanami run path/to/script.rb
        # $ bundle exec hanami run 'puts Hanami.app["repos.user_repo"].all.count'
        #
        # @since 2.0.0
        # @api private
        class Run < Hanami::CLI::Command
          RunError = Class.new(StandardError)

          desc "Run code in the context of the application"

          example [
            "path/to/script.rb                     # Run a Ruby script in the context of the application",
            "'puts Hanami.app[\"repos.user_repo\"].all.count' # Run inline Ruby code in the context of the application",
          ]

          argument :code_or_path, required: true, desc: "Path to a Ruby file or inline Ruby code to be executed"

          def initialize(command_exit: method(:exit), **opts)
            super(**opts)
            @command_exit = command_exit
          end

          # rubocop:disable Metrics/AbcSize
          def call(code_or_path:, **)
            require "hanami/prepare"

            if File.exist?(code_or_path)
              validate_file_path!(code_or_path)
              Kernel.load code_or_path
            else
              validate_inline_code!(code_or_path)
              begin
                eval(code_or_path, binding, __FILE__, __LINE__) # rubocop:disable Security/Eval
              rescue SyntaxError => e
                err.puts "Syntax error in code: #{e.message}"
                raise RunError, "Syntax error in code: #{e.message}"
              rescue NameError => e
                err.puts "Name error in code: #{e.message}"
                raise RunError, "Name error in code: #{e.message}"
              rescue StandardError => e
                err.puts "Error executing code: #{e.class}: #{e.message}"
                raise RunError, "Error executing code: #{e.class}: #{e.message}"
              end
            end
          rescue RunError
            @command_exit.call(1)
          end
          # rubocop:enable Metrics/AbcSize

          private

          def validate_file_path!(file_path)
            errors = []

            # Ensure the file is a Ruby file
            unless file_path.end_with?(".rb")
              errors << "Error: Only Ruby files (.rb) are allowed"
            end

            # Resolve the absolute path and ensure it's within the app directory
            resolved_path = File.expand_path(file_path)
            app_root = File.expand_path(Dir.pwd)

            unless resolved_path.start_with?(app_root)
              errors << "Error: File must be within the application directory"
            end

            # Check file size (prevent loading extremely large files)
            file_size = File.size(file_path)
            if file_size > 10 * 1024 * 1024 # 10MB limit
              errors << "Error: File too large (maximum 10MB allowed)"
            end

            unless errors.empty?
              errors.each { |error| err.puts error }
              raise RunError, errors.join("\n")
            end
          end

          def validate_inline_code!(code)
            # Basic validation for inline code
            if code.length > 10_000 # 10KB limit for inline code
              err.puts "Error: Inline code too long (maximum 10,000 characters allowed)"
              raise RunError, "Error: Inline code too long (maximum 10,000 characters allowed)"
            end
          end
        end
      end
    end
  end
end
