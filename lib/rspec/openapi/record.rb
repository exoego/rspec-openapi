RSpec::OpenAPI::Record = Struct.new(
  :method,                # @param [String]  - "GET"
  :path,                  # @param [String]  - "/v1/status/:id"
  :path_params,           # @param [Hash]    - {:controller=>"v1/statuses", :action=>"create", :id=>"1"}
  :query_params,          # @param [Hash]    - {:query=>"string"}
  :request_params,        # @param [Hash]    - {:request=>"body"}
  :request_content_type,  # @param [String]  - "application/json"
  :summary,               # @param [String]  - "v1/statuses #show"
  :tags,                  # @param [Array]   - ["Status"]
  :description,           # @param [String]  - "returns a status"
  :status,                # @param [Integer] - 200
  :response_body,         # @param [Object]  - {"status" => "ok"}
  :response_content_type, # @param [String]  - "application/json"
  :response_content_disposition, # @param [String]  - "inline"
  keyword_init: true,
)
