# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class HeterogeneousNonHashItems < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
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
