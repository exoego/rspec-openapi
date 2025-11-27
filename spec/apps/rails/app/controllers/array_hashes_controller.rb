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
          "validations" => {
            "presence" => true
          }
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
          "validations" => nil
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
          }
        },
        {
          "id" => 2,
          "metadata" => {
            "author" => "Bob",
            "version" => "2.0",
            "reviewed" => true
          }
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
          }
        },
        {
          "id" => 2,
          "config" => {
            "port" => "3000",
            "host" => "example.com",
            "ssl" => true
          }
        }
      ]
    }
    render json: response
  end
end
