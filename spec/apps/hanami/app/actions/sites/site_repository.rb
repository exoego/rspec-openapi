# frozen_string_literal: true

module HanamiTest
  module Actions
    module Sites
      module SiteRepository
        class RecordNotFound < StandardError; end

        def find_site(name = nil)
          case name
          when 'abc123', nil
            {
              name: name,
            }
          else
            raise RecordNotFound
          end
        end
      end
    end
  end
end
