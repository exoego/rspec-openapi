# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require 'bundler'
require 'fileutils'
require 'minitest/autorun'
require File.expand_path('../apps/rails/config/environment', __dir__)

RSpec::OpenAPI.openapi_version = '3.0.3'
RSpec::OpenAPI.title = 'OpenAPI Documentation'
output = ENV.fetch('OPENAPI_OUTPUT', nil)
RSpec::OpenAPI.path = File.expand_path("../apps/rails/doc/minitest_parallel_openapi.#{output}", __dir__)
RSpec::OpenAPI.servers = [{ url: 'http://localhost:3000' }]

# Each test writes its pid here so the outer spec can verify the tests really
# ran in forked workers rather than in the main process.
PARALLEL_PID_DIR = File.expand_path('../apps/rails/tmp/parallel_pids', __dir__)
FileUtils.mkdir_p(PARALLEL_PID_DIR)
File.write(File.join(PARALLEL_PID_DIR, 'main.pid'), Process.pid.to_s)

# Rails >= 7.1 skips forking below this test-count threshold. Older Rails has
# no threshold and always forks.
ActiveSupport.test_parallelization_threshold = 0 if ActiveSupport.respond_to?(:test_parallelization_threshold=)

# Minitest 6 removed Minitest.run_one_method, but activesupport's parallel
# worker (as of 8.0) still calls it. Minitest 6's Test#run returns a Result,
# which is the contract run_one_method had.
unless Minitest.respond_to?(:run_one_method)
  def Minitest.run_one_method(klass, method_name)
    klass.new(method_name).run
  end
end

module RailsParallelIntegrationTests
  class ParallelTestCase < ActionDispatch::IntegrationTest
    parallelize(workers: 3)

    def record_pid
      File.write(File.join(PARALLEL_PID_DIR, "worker_#{Process.pid}.pid"), Process.pid.to_s)
    end
  end

  class TablesTest < ParallelTestCase
    openapi!

    test 'returns tables' do
      record_pid
      get '/tables', headers: { authorization: 'k0kubun' }
      assert_response 200
    end

    test 'returns a table' do
      record_pid
      get '/tables/1', headers: { authorization: 'k0kubun' }
      assert_response 200
    end
  end

  class ImagesTest < ParallelTestCase
    openapi!

    test 'returns an image payload' do
      record_pid
      get '/images/1'
      assert_response 200
    end

    test 'returns a list of images' do
      record_pid
      get '/images'
      assert_response 200
    end
  end

  class ExtraRoutesTest < ParallelTestCase
    openapi!

    test 'returns the block content' do
      record_pid
      get '/test_block'
      assert_response 200
    end

    test 'returns additional properties' do
      record_pid
      get '/additional_properties'
      assert_response 200
    end
  end
end
