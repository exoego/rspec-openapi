# frozen_string_literal: true

require "irb"
require_relative "core"

module Hanami
  module CLI
    module Repl
      # @since 2.0.0
      # @api private
      class Irb < Core
        # @since 2.0.0
        # @api private
        def start
          $stdout.sync = true

          ARGV.shift until ARGV.empty?
          TOPLEVEL_BINDING.eval("self").extend(context)

          # Initializes the IRB.conf; our own conf changes must be after this
          IRB.setup(nil)

          IRB.conf[:PROMPT][:HANAMI] = {
            AUTO_INDENT: true,
            PROMPT_I: "#{prompt}> ",
            PROMPT_N: "#{prompt}> ",
            PROMPT_S: "#{prompt}%l ",
            PROMPT_C: "#{prompt}* ",
            RETURN: "=> %s\n"
          }

          IRB.conf[:PROMPT_MODE] = :HANAMI

          IRB::Irb.new.run
        end
      end
    end
  end
end
