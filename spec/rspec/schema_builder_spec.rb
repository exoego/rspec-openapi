# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::OpenAPI::SchemaBuilder do
  include SpecHelper

  describe "#build" do
    let(:record) do
      double(
        title: "Title",
        http_method: "GET",
        path: "/api/endpoint",
        path_params: {},
        query_params: {},
        request_params: {},
        required_request_params: [],
        request_content_type: nil,
        request_headers: [],
        summary: "summary",
        tags: ["Api::Endpoint"],
        formats: nil,
        operation_id: nil,
        description: "does something",
        security: nil,
        deprecated: nil,
        status: 200,
        response_body:
         {
           "users" => [
             {
               "label" => "Jane Doe",
               "value" => "jane_doe"
             },
             {
               "label" => nil,
               "value" => "unknown"
             }
           ],
         },
        response_headers: [],
        response_content_type: "application/json",
        response_content_disposition: nil
      )
    end

    subject { described_class.build(record) }

    it {
      expect(subject).to eq({
                              paths: {
                                "/api/endpoint" => {
                                  "get" => {
                                    summary: "summary",
                                    tags: ["Api::Endpoint"],
                                    responses: {
                                      "200" => {
                                        description: "does something",
                                        content: {
                                          "application/json" => {
                                            schema: {
                                              type: "object",
                                              properties: {
                                                "users" => {
                                                  type: "array",
                                                  items: {
                                                    type: "object",
                                                    properties: {
                                                      "label" => {
                                                        type: "string",
                                                        nullable: true
                                                      },
                                                      "value" => {
                                                        type: "string"
                                                      }
                                                    },
                                                    required: ["label", "value"]
                                                  }
                                                }
                                              },
                                              required: ["users"]
                                            },
                                            example: {
                                              "users" => [
                                                {
                                                  "label" => "Jane Doe",
                                                  "value" => "jane_doe"
                                                },
                                                {
                                                  "label" => nil,
                                                  "value" => "unknown"
                                                }
                                              ]
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            })
    }
  end
end
