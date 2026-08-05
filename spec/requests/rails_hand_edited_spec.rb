# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Re-records over a document holding shapes only a person writes. Response codes
# are never cleaned up, so the hand-written ones in the fixture survive the run
# and the scan for referenced components has to cope with them:
#
#   '503' has a media type with no schema at all, where that scan looks for one.
#   '409' has a oneOf mixing a $ref, a list item left empty mid-edit, and an
#         inline schema, so the scan meets all three.
#
# The component the 409 refers to comes out empty, because nothing recorded
# fills it in. The fixture pins that as it stands today.
RSpec::OpenAPI.title = 'Hand edited'
RSpec::OpenAPI.openapi_version = '3.2.0'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/hand_edited/openapi.yaml', __dir__)

RSpec.describe 'hand-edited document shapes', type: :request do
  it 'records over them without disturbing them' do
    get '/example_mode_single'
    expect(response).to have_http_status(:ok)
  end
end
