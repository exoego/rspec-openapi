RSpec::OpenAPI::Record = Struct.new(
  :method,      # @param [String]  - ex) GET
  :path,        # @param [String]  - ex) /v1/status
  :description, # @param [String]  - ex) returns a status
  :status,      # @param [Integer] - ex) 200
  :body,        # @param [Object]  - ex) {"status" => "ok"}
)
