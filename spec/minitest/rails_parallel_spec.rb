# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'yaml'

RSpec.describe 'rails integration minitest with parallelize' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/minitest_parallel_openapi.yaml', repo_root)
  end

  let(:pid_dir) do
    File.expand_path('spec/apps/rails/tmp/parallel_pids', repo_root)
  end

  it 'collects records from forked workers into spec/apps/rails/doc/minitest_parallel_openapi.yaml' do
    FileUtils.rm_rf(pid_dir)
    org_yaml = YAML.safe_load(File.read(openapi_path))
    minitest 'spec/integration_tests/rails_parallel_test.rb', openapi: true, output: :yaml
    new_yaml = YAML.safe_load(File.read(openapi_path))

    main_pid = File.read(File.join(pid_dir, 'main.pid'))
    worker_pids = Dir.glob(File.join(pid_dir, 'worker_*.pid')).map { |f| File.read(f) }
    expect(worker_pids).not_to be_empty
    expect(worker_pids).not_to include(main_pid)

    expect(new_yaml).to eq org_yaml
  ensure
    FileUtils.rm_rf(pid_dir)
  end
end
