# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module DB
          # @api private
          class Seed < DB::Command
            SEEDS_PATH = "config/db/seeds.rb"
            private_constant :SEEDS_PATH

            desc "Load seed data"

            def call(app: false, slice: nil, **)
              # We use `databases` below to discover the databases throughout the app and slices. It
              # yields every database, so in a slice with multiple gateways, we'll see multiple
              # databases for the slice.
              #
              # Since `db seed` is intended to run over whole slices only (not per-gateway), keep
              # track of the seeded slices here, so we can avoid seeding a slice multiple times.
              seeded_slices = []

              databases(app: app, slice: slice).each do |database|
                next if seeded_slices.include?(database.slice)

                seeds_path = database.slice.root.join(SEEDS_PATH)

                unless seeds_path.file?
                  out.puts "no seeds found at #{seeds_path.relative_path_from(database.slice.app.root)}"
                  next
                end

                relative_seeds_path = seeds_path.relative_path_from(database.slice.app.root)
                measure "seed data loaded from #{relative_seeds_path}" do
                  load seeds_path.to_s
                end

                seeded_slices << database.slice
              end
            end
          end
        end
      end
    end
  end
end
