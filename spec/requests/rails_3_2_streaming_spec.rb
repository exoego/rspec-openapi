# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Exercises `itemSchema` for the sequential (streaming) media types other than
# the NDJSON case already covered by rails_spec: JSON Text Sequences and SSE.
# `itemSchema` is a 3.2-only construct, so this spec pins the version to 3.2.
RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.openapi_version = '3.2.0'
# Root-level tags are a declarative pass-through emitted into the document root.
RSpec::OpenAPI.root_tags = [{ name: 'Streaming', summary: 'Streaming endpoints' }]
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/rspec_openapi_3.2_streaming.yaml', __dir__)

RSpec.describe 'OpenAPI 3.2 streaming media types', type: :request do
  it 'records a JSON Text Sequence (application/json-seq) as itemSchema' do
    get '/stream_json_seq'
    expect(response).to have_http_status(:ok)
  end

  it 'records a Server-Sent Events stream (text/event-stream) as itemSchema' do
    get '/stream_sse'
    expect(response).to have_http_status(:ok)
  end

  it 'records an SSE stream that ends with a trailing blank line' do
    get '/stream_sse_blank_end'
    expect(response).to have_http_status(:ok)
  end

  it 'falls back to a string schema when a stream has no parseable items' do
    get '/stream_empty'
    expect(response).to have_http_status(:ok)
  end
end
