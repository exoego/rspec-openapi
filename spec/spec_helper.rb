module SpecHelper
  def repo_root
    File.expand_path('..', __dir__)
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
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
