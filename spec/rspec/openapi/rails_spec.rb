require 'spec_helper'
require 'open3'

RSpec.describe RSpec::OpenAPI do
  include SpecHelper

  describe 'rails request spec' do
    let(:openapi_path) { File.expand_path('spec/rails/doc/openapi.yaml', repo_root) }

    it 'generates the same spec/railsapp/doc/openapi.yaml' do
      FileUtils.rm_f(openapi_path)
      rspec 'spec/requests/rails', openapi: true
      assert_run 'git', 'diff', '--exit-code', '--', openapi_path
    end
  end
end
