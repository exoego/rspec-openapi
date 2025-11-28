# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class NestedObjects < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "items" => [
              {
                "id" => 1,
                "metadata" => {
                  "author" => "Alice",
                  "version" => "1.0"
                },
                "actions" => [
                  {
                    "label" => "Duplicate",
                    "modal" => {
                      "confirm_action" => {
                        "label" => "Duplicate"
                      }
                    }
                  },
                  {
                    "label" => "Edit",
                  },
                  {
                    "label" => "Something Else Again",
                    "modal" => {
                      "confirm_action" => {
                        "label" => nil
                      }
                    }
                  }
                ]
              },
              {
                "id" => 2,
                "metadata" => {
                  "author" => "Bob",
                  "version" => "2.0",
                  "reviewed" => true
                },
                "actions" => [
                  {
                    "label" => "Duplicate",
                    "modal" => {
                      "confirm_action" => {
                        "label" => "Duplicate"
                      }
                    }
                  },
                  {
                    "label" => "Edit",
                  },
                  {
                    "label" => "Something Else Again",
                    "modal" => {
                      "confirm_action" => {
                        "label" => nil
                      }
                    }
                  }
                ]
              },
              {
                "id" => 3,
                "metadata" => {
                  "author" => "Charlie"
                }
              }
            ]
          }.to_json
        end
      end
    end
  end
end
