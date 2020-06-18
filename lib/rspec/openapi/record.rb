RSpec::OpenAPI::Record = Struct.new(
  :method,         # @param [String]  - "GET"
  :path,           # @param [String]  - "/v1/status/:id"
  :path_params,    # @param [Hash]    - {:controller=>"v1/statuses", :action=>"create", :id=>"1"}
  :query_params,   # @param [Hash]    - {:query=>"string"}
  :request_params, # @param [Hash]    - {:request=>"body"}
  :controller,     # @param [String]  - "v1/statuses"
  :action,         # @param [String]  - "show"
  :description,    # @param [String]  - "returns a status"
  :status,         # @param [Integer] - 200
  :response,       # @param [Object]  - {"status" => "ok"}
  :content_type,   # @param [String]  - "application/json"
  keyword_init: true,
)
