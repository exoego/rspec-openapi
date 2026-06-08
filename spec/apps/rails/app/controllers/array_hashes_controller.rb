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

  def nested_arrays_across_items
    response = {
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
    }
    render json: response
  end

  # Regression probe (#2): arrays-of-arrays with divergent inner element types.
  # Outer items each contain `values` whose items are themselves arrays of
  # differently-typed scalars. Expect the merged items schema to express both
  # types (oneOf integer/string). If it shows only the first type, the bug is real.
  def regression_arrays_of_arrays_divergent
    response = {
      "items" => [
        { "values" => [[1, 2, 3]] },
        { "values" => [["x", "y", "z"]] },
      ],
    }
    render json: response
  end

  # Regression probe (#3): nested array empty in one outer item, populated in another,
  # at depth >= 2 of merge recursion. Old merge_multi_recursive would .first.dup arrays
  # (losing the populated schema); new merge_multi recurses into items and forces every
  # property nullable. Expect a sensible merge (populated schema preserved, required kept).
  def regression_nested_array_empty_then_populated
    response = {
      "items" => [
        { "wrapper" => { "tags" => [] } },
        { "wrapper" => { "tags" => [{ "name" => "first", "value" => 1 }] } },
      ],
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
