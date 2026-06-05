# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class NestedArraysAcrossItems < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "form" => [
              {
                "label" => "User details",
                "inputs" => [
                  {
                    "type" => "columns",
                    "columns" => [
                      {
                        "input" => {
                          "name" => "first_name",
                          "type" => "text",
                          "validations" => {
                            "presence" => true
                          }
                        }
                      }
                    ]
                  },
                  {
                    "type" => "text",
                    "name" => "email",
                    "validations" => {
                      "presence" => true
                    }
                  }
                ]
              },
              {
                "label" => "Billing details",
                "inputs" => [
                  {
                    "type" => "columns",
                    "columns" => [
                      {
                        "input" => {
                          "name" => "country_code",
                          "type" => "dropdown",
                          "validations" => nil,
                          "answer_options" => [
                            {"label" => "United Kingdom", "value" => "GB"}
                          ]
                        }
                      }
                    ]
                  }
                ]
              }
            ]
          }.to_json
        end
      end
    end
  end
end
