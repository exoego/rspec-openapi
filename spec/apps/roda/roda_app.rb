# frozen_string_literal: true

require 'roda'

class RodaApp < Roda
  plugin :json, classes: [Array, Hash]

  route do |r|
    r.on 'roda' do
      # POST /roda
      r.post do
        params = JSON.parse(request.body.read, symbolize_names: true)
        params.merge({ name: 'hello' })
      end
    end

    # Test routes for example_mode feature testing
    r.get 'example_mode_none' do
      { status: 'ok' }
    end

    r.get 'example_mode_single' do
      { status: 'single' }
    end

    r.get 'example_mode_multiple' do
      { status: 'multiple' }
    end

    r.get 'example_mode_mixed' do
      { status: 'mixed' }
    end

    r.get 'example_mode_inherit' do
      { status: 'inherit' }
    end

    r.get 'example_mode_override_single' do
      { status: 'override_single' }
    end

    r.get 'example_mode_override_none' do
      { status: 'override_none' }
    end

    r.get 'example_mode_disabled' do
      { status: 'disabled' }
    end

    r.get 'example_mode_disabled_single' do
      { status: 'disabled_single' }
    end

    r.get 'example_mode_disabled_multiple' do
      { status: 'disabled_multiple' }
    end

    r.get 'example_mode_disabled_none' do
      { status: 'disabled_none' }
    end

    r.post 'tags' do
      response.status = 201
      { created: true }
    end

    r.get 'custom_example_key' do
      { data: 'custom_key' }
    end

    r.get 'custom_example_name' do
      { data: 'custom_name' }
    end

    r.get 'example_summary_disabled' do
      { data: 'no_summary' }
    end

    r.get 'empty_example_name' do
      { data: 'empty_name' }
    end

    # Test route for nested arrays (key_transformer coverage)
    r.get 'nested_arrays_test' do
      {
        items: [
          { name: 'first', tags: %w[a b c] },
          { name: 'second', tags: %w[x y z] }
        ],
        matrix: [[1, 2], [3, 4]]
      }
    end

    # Test route for invalid example_mode error handling
    r.get 'invalid_example_mode' do
      { status: 'ok' }
    end
  end
end
