# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Records conflicting types over a document that seed.yaml wrote by hand.
# Every route picks its body by the X-Variant header, so the recorded
# operation shows nothing but the bodies.
RSpec::OpenAPI.title = 'oneOf merge'
RSpec::OpenAPI.openapi_version = '3.1.0'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/oneof_merge/openapi.yaml', __dir__)

RSpec.describe 'oneOf merging across examples', type: :request do
  def record(path, variant: nil)
    get path, headers: variant ? { 'X-Variant' => variant } : {}
    expect(response).to have_http_status(:ok)
  end

  describe 'a hand-written oneOf left empty' do
    it('records a string') { record '/oneof_merge/empty_one_of' }
    it('records an integer') { record '/oneof_merge/empty_one_of', variant: 'integer' }
  end
end
