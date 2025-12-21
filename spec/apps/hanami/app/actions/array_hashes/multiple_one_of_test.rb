# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class MultipleOneOfTest < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "data" => {
              "form" => [
                {
                  "inputs" => [
                    {
                      "value" => 'John Doe',
                    },
                    {
                      "value" =>
                        'some_email_123@someone.com',
                    },
                    {
                      "value" => 'In progress',
                    },
                    {
                      "value" => '2025-12-11T06:25:20.770+00:00',
                    },
                  ],
                },
                {
                  "inputs" => [
                    {
                      "value" => nil,
                    },
                    {
                      "value" => 'user_1',
                    },
                    {
                      "value" => 'user_2',
                    },
                  ],
                },
                {
                  "inputs" => [
                    {
                      "value" => false,
                    },
                    {
                      "value" => 'Some organisation',
                    },
                    {
                      "value" => 'organisation_1',
                    },
                    {
                      "value" => [
                        'organisation_1',
                        'organisation_2',
                        'organisation_3',
                      ],
                    },
                  ],
                },
                {
                  "inputs" => [
                    {
                      "value" => 'Initialized',
                    },
                    {
                      "value" => 'Initialized',
                    },
                    {
                      "value" => 'Initialized',
                    },
                    {
                      "value" => 'Initialized',
                    },
                    {
                      "value" => nil,
                    },
                  ],
                },
                {
                  "inputs" => [
                    {
                      "value" => nil,
                    },
                    {
                      "value" => nil,
                    },
                    {
                      "value" => nil,
                    },
                    {
                      "value" => nil,
                    },
                  ],
                },
              ],
            },
          }.to_json
        end
      end
    end
  end
end
