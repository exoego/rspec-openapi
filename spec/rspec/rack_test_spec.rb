require 'spec_helper'

RSpec.describe 'rack-test spec' do
  include SpecHelper

  # let(:openapi_path) do
  #   File.expand_path('spec/roda/doc/openapi.yaml', repo_root)
  # end

  it 'generates the same spec/roda/doc/openapi.yaml' do
    # FileUtils.rm_f(openapi_path)
    rspec 'spec/requests/roda_spec.rb', openapi: true
    # assert_run 'git', 'diff', '--exit-code', '--', openapi_path
  end
end
