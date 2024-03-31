# frozen_string_literal: true

module HanamiTest
  module Actions
    module Images
      class UploadMultiple < HanamiTest::Action
        # format :multipart

        def handle(_request, response)
          png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjPQBoAAAAASUVORK5CYII='
                .unpack('m').first

          response.format = :png
          response.body = png
          response.headers.merge!(
            {
              'Content-Type' => 'image/png',
              'Content-Disposition' => 'inline'
            }
          )
        end
      end
    end
  end
end
