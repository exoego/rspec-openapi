# frozen_string_literal: true

require "rake"

module Hanami
  module CLI
    # Install Rake tasks in an app
    #
    # @since 2.0.0
    class RakeTasks
      include Rake::DSL

      # @since 2.0.0
      # @api private
      @tasks = []

      # @since 2.0.0
      # @api private
      @_mutex = Mutex.new

      # @since 2.0.0
      # @api private
      def self.register_tasks(&blk)
        @_mutex.synchronize do
          @tasks << blk
          @tasks.uniq!
        end
      end

      # @since 2.0.0
      # @api private
      def self.tasks
        @_mutex.synchronize do
          @tasks
        end
      end

      # @since 0.6.0
      # @api private
      def self.install_tasks
        new.call(tasks)
      end

      # @since 2.0.0
      # @api private
      def call(tasks)
        tasks.each(&:call)
      end
    end
  end
end

Hanami::CLI::Bundler.require(:cli)
