require 'spec_helper'
require 'open3'

RSpec.describe RSpec::OpenAPI do
  def repo_root
    File.expand_path('../../..', __dir__)
  end

  def assert_run(*args)
    out, err, status = Open3.capture3(*args)
    expect(status.success?).to eq(true), "stdout:\n#{out}\nstderr:\n#{err}"
  end

  def rspec(*args, openapi: false)
    env = { 'OPENAPI' => ('1' if openapi) }.compact
    Bundler.with_unbundled_env do
      Dir.chdir(repo_root) do
        assert_run env, 'bundle', 'exec', 'rspec', '--pattern', 'spec/requests/**/*_spec.rb', *args
      end
    end
  end

  describe 'rails request spec' do
    let(:openapi_path) { File.expand_path('spec/rails/doc/openapi.yaml', repo_root) }

    it 'generates the same spec/railsapp/doc/openapi.yaml' do
      FileUtils.rm_f(openapi_path)
      rspec 'spec/requests/rails', openapi: true
      assert_run 'git', 'diff', '--exit-code', '--', openapi_path
    end
  end
end
