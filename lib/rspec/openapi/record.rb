RSpec::OpenAPI::Record = Struct.new(
  :method,       # @param [String]  - ex) GET
  :path,         # @param [String]  - ex) /v1/status/:id
  :controller,   # @param [String]  - ex) v1/statuses
  :action,       # @param [String]  - ex) show
  :description,  # @param [String]  - ex) returns a status
  :status,       # @param [Integer] - ex) 200
  :body,         # @param [Object]  - ex) {"status" => "ok"}
  :content_type, # @param [String]  - ex) application/json
  keyword_init: true,
)
