class ArrayHashesController < ApplicationController
  def nullable
    response = {
      "users" => [
        {
          "label" => "John Doe",
          "value" => "john_doe",
          "admin" => true
        },
        {
          "label" => "Jane Doe",
          "value" => "jane_doe"
        },
        {
          "label" => nil,
          "value" => "invited",
          "invited" => true
        },
      ],
    }
    render json: response
  end

  def non_nullable
    response = {
      "users" => [
        {
          "label" => "Jane Doe",
          "value" => "jane_doe"
        },
        {
          "label" => "John Doe",
          "value" => "john_doe"
        }
      ],
    }
    render json: response
  end

  def nested
    response = {
      "fields" => [
        {
          "id" => "country_code",
          "options" => [
            {
              "id" => "us",
              "label" => "United States"
            },
            {
              "id" => "ca",
              "label" => "Canada"
            }
          ],
          "validations" => nil,
          "always_nil" => nil

        },
        {
          "id" => "region_id",
          "options" => [
            {
              "id" => 1,
              "label" => "New York"
            },
            {
              "id" => 2,
              "label" => "California"
            }
          ],
          "validations" => {
            "presence" => true
          },
          "always_nil" => nil
        }
      ]
    }
    render json: response
  end

  def empty_array
    response = {
      "items" => []
    }
    render json: response
  end

  def single_item
    response = {
      "items" => [
        {
          "id" => 1,
          "name" => "Item 1"
        }
      ]
    }
    render json: response
  end

  def non_hash_items
    response = {
      "items" => ["string1", "string2", "string3"]
    }
    render json: response
  end

  def nested_arrays
    response = {
      "items" => [
        {
          "id" => 1,
          "tags" => ["ruby", "rails"]
        },
        {
          "id" => 2,
          "tags" => ["python", "django"]
        },
        {
          "id" => 3,
          "tags" => ["javascript"]
        }
      ]
    }
    render json: response
  end

  def nested_objects
    response = {
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
                  "label" => "Duplicate",
                  "endpoint" => nil
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
                  "label" => nil,
                  "endpoint" => nil
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
                  "label" => "Duplicate",
                  "endpoint" => nil
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
                  "label" => nil,
                  "endpoint" => nil
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
    }
    render json: response
  end

  def mixed_types_nested
    response = {
      "items" => [
        {
          "id" => 1,
          "config" => {
            "port" => 8080,
            "host" => "localhost"
          },
          "form" => [
            {
              "value" => "John Doe",
              "options" => [
                {"label" => "John Doe", "value" => "john_doe"},
                {"label" => "Jane Doe", "value" => "jane_doe"}
              ]
            },
            {
              "value" => [],
              "options" => {
                "endpoint" => "some/endpoint"
              }
            },
            {
              "value" => nil,
              "options" => nil
            },
          ]
        },
        {
          "id" => 2,
          "config" => {
            "port" => "3000",
            "host" => "example.com",
            "ssl" => true
          },
          "form" => nil
        },
        {
          "id" => 3,
          "config" => {
            "port" => "9010",
            "host" => "foo.example.com",
            "ssl" => true
          }
        },
      ]
    }
    render json: response
  end

  def multiple_one_of_test
    response = {
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
    }
    render json: response
  end
end
