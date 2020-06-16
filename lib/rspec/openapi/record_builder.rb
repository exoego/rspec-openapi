class << RSpec::OpenAPI::RecordBuilder = Object.new
  def build(example)
    RSpec::OpenAPI::Record.new(
      method: 'GET',
      path: '/v1/status',
      description: 'returns a status',
      status: 200,
      body: { 'status' => 'ok' },
    )
  end
end
