# frozen_string_literal: true

RSpec::OpenAPI::Record = Struct.new(
  :http_method,           # @param [String]  - "GET"
  :path,                  # @param [String]  - "/v1/status/:id"
  :path_params,           # @param [Hash]    - {:controller=>"v1/statuses", :action=>"create", :id=>"1"}
  :query_params,          # @param [Hash]    - {:query=>"string"}
  :request_params,        # @param [Hash]    - {:request=>"body"}
  :required_request_params, # @param [Array]    - ["param1", "param2"]
  :request_content_type,  # @param [String]  - "application/json"
  :request_headers,       # @param [Array]  - [["header_key1", "header_value1"], ["header_key2", "header_value2"]]
  :summary,               # @param [String]  - "v1/statuses #show"
  :tags,                  # @param [Array]   - ["Status"]
  :operation_id,          # @param [String]   - "request-1234"
  :description,           # @param [String]  - "returns a status"
  :security,              # @param [Array]  - [{securityScheme1: []}]
  :status,                # @param [Integer] - 200
  :response_body,         # @param [Object]  - {"status" => "ok"}
  :response_headers,      # @param [Array]  - [["header_key1", "header_value1"], ["header_key2", "header_value2"]]
  :response_content_type, # @param [String]  - "application/json"
  :response_content_disposition, # @param [String]  - "inline"
  keyword_init: true,
)
