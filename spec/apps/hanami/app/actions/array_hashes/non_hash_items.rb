# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class NonHashItems < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "items" => ["string1", "string2", "string3"],
            "export_options" => [
              ["Default", nil],
              ["Mean", "mean"],
              ["Median", "median"]
            ],
            "leading_null" => [
              [nil, "north"]
            ],
            "divergent_scalars" => [
              [1, "one"]
            ]
          }.to_json
        end
      end
    end
  end
end
