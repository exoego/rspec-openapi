class << RSpec::OpenAPI::RecordRegistry = Object.new
  # @param [Hash{ Array<String> => Array<RSpec::OpenAPI::Record> }] - { ["method", "path"] => [#<RSpec::OpenAPI::Record>, ...] }
  @request_records = Hash.new { |h, k| h[k] = [] }

  # @param [RSpec::OpenAPI::Record]
  def add(record)
    @request_records[[record.method, record.path]] << record
  end
end
