# frozen_string_literal: true

require "dry/inflector"
require "dry/files"
require "shellwords"
require_relative "../../../naming"
require_relative "../../../errors"

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @since 2.2.0
          # @api private
          class Command < App::Command
            option :slice, required: false, desc: "Slice name"

            attr_reader :generator
            private :generator

            # @since 2.2.0
            # @api private
            def initialize(fs:, out:, **)
              super
              @generator = generator_class.new(fs:, inflector:, out:)
            end

            # @since 2.2.0
            # @api private
            def generator_class
              # Must be implemented by subclasses, with initialize method that takes:
              # fs:, out:
            end

            # @since 2.2.0
            # @api private
            def call(name:, slice: nil, **opts)
              slice ||= detect_slice_from_cwd

              if slice.nil?
                generator.call(
                  key: name,
                  namespace: app.namespace,
                  base_path: "app",
                  **opts,
                )
                return
              end

              slice_root = slice.respond_to?(:root) ? slice.root : detect_slice_root(slice)
              raise MissingSliceError.new(slice) unless fs.exist?(slice_root)

              generator.call(
                key: name,
                namespace: slice,
                base_path: slice_root,
                **opts,
              )
            end

            private

            def detect_slice_from_cwd
              slices_by_root = app.slices.with_nested.each.to_h { |slice| [slice.root.to_s, slice] }
              slices_by_root[fs.pwd]
            end

            # Returns the root for the given slice name.
            #
            # This currently works with top-level slices only, and it simply appends the slice's
            # name onto the "slices/" dir, returning e.g. "slices/main" when given "main".
            #
            # TODO: Make this work with nested slices when given slash-delimited slice names like
            # "parent/child", which should look for "slices/parent/slices/child".
            #
            # This method makes two checks for the slice root (building off both `app.root` as well
            # as `fs`). This is entirely to account for how we test commands, with most tests using
            # an in-memory `fs` adapter, any files created via which will be invisible to the `app`,
            # which doesn't know about the `fs`.
            #
            # FIXME: It would be better to find a way for this to make one check only. An ideal
            # approach would be to use the slice_name to find actual slice registered within
            # `app.slices`. To do this, we'd probably need to stop testing with an in-memory `fs`
            # here.
            def detect_slice_root(slice_name)
              slice_root_in_fs = fs.join("slices", inflector.underscore(slice_name))
              return slice_root_in_fs if fs.exist?(slice_root_in_fs)

              app.root.join("slices", inflector.underscore(slice_name))
            end
          end
        end
      end
    end
  end
end
