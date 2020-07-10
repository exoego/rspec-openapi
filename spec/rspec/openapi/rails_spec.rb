require 'spec_helper'

RSpec.describe 'rails request spec' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/rails/doc/openapi.yaml', repo_root)
  end

  it 'generates the same spec/rails/doc/openapi.yaml' do
    FileUtils.rm_f(openapi_path)
    rspec 'spec/requests/rails', openapi: true
    assert_run 'git', 'diff', '--exit-code', '--', openapi_path
  end
end
