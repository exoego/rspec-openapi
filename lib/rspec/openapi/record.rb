RSpec::OpenAPI::Record = Struct.new(
  :method,                # @param [String]  - "GET"
  :operation_description, # @param [String]  - "returns a status"
  :path,                  # @param [String]  - "/v1/status/:id"
  :path_params,           # @param [Hash]    - {:controller=>"v1/statuses", :action=>"create", :id=>"1"}
  :query_params,          # @param [Hash]    - {:query=>"string"}
  :request_content_type,  # @param [String]  - "application/json"
  :request_params,        # @param [Hash]    - {:request=>"body"}
  :response_body,         # @param [Object]  - {"status" => "ok"}
  :response_content_type, # @param [String]  - "application/json"
  :response_description,  # @param [String]  - "returns a status"
  :status,                # @param [Integer] - 200
  :summary,               # @param [String]  - "v1/statuses #show"
  :tags,                  # @param [Array]   - ["Status"]
  keyword_init: true,
)
