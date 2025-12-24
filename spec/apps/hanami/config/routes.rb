# frozen_string_literal: true
require 'rack_test/app'

module HanamiTest
  class Routes < Hanami::Routes
    # Add your routes here. See https://guides.hanamirb.org/routing/overview/ for details.
    get '/secret_items', to: 'secret_items.index'

    get '/tables', to: 'tables.index'
    get '/tables/:id', to: 'tables.show'
    post '/tables', to: 'tables.create'
    patch '/tables/:id', to: 'tables.update'
    delete '/tables/:id', to: 'tables.destroy'

    get '/images', to: 'images.index'
    get '/images/:id', to: 'images.show'
    post '/images/upload', to: 'images.upload'
    post '/images/upload_nested', to: 'images.upload_nested'
    post '/images/upload_multiple', to: 'images.upload_multiple'
    post '/images/upload_multiple_nested', to: 'images.upload_multiple_nested'

    post '/users', to: 'users.create'
    get '/users/:id', to: 'users.show'
    get '/users/active', to: 'users.active'

    get '/sites/:name', to: 'sites.show'
    get '/array_hashes/nullable', to: 'array_hashes.nullable'
    get '/array_hashes/non_nullable', to: 'array_hashes.non_nullable'
    get '/array_hashes/nested', to: 'array_hashes.nested'
    get '/array_hashes/empty_array', to: 'array_hashes.empty_array'
    get '/array_hashes/single_item', to: 'array_hashes.single_item'
    get '/array_hashes/non_hash_items', to: 'array_hashes.non_hash_items'
    get '/array_hashes/nested_arrays', to: 'array_hashes.nested_arrays'
    get '/array_hashes/nested_objects', to: 'array_hashes.nested_objects'
    get '/array_hashes/mixed_types_nested', to: 'array_hashes.mixed_types_nested'
    get '/array_hashes/multiple_one_of_test', to: 'array_hashes.multiple_one_of_test'

    get '/test_block', to: ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['A TEST']] }

    # Test routes for example_mode feature testing
    get '/example_mode_none', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']] }
    get '/example_mode_single', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"single"}']] }
    get '/example_mode_multiple', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"multiple"}']] }
    get '/example_mode_mixed', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"mixed"}']] }
    get '/example_mode_inherit', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"inherit"}']] }
    get '/example_mode_override_single', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"override_single"}']] }
    get '/example_mode_override_none', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"override_none"}']] }
    get '/example_mode_disabled', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"disabled"}']] }
    get '/example_mode_disabled_single', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"disabled_single"}']] }
    get '/example_mode_disabled_multiple', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"disabled_multiple"}']] }
    get '/example_mode_disabled_none', to: ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"disabled_none"}']] }

    # Test route for array with primitive values in request params
    post '/tags', to: ->(_env) { [201, { 'Content-Type' => 'application/json' }, ['{"created":true}']] }

    slice :my_engine, at: '/my_engine' do
      get '/test', to: ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['ANOTHER TEST']] }
      get '/eng/example', to: 'eng.example'
    end

    scope 'admin' do
      scope 'masters' do
        get '/extensions', to: 'extensions.index'
        post '/extensions', to: 'extensions.create'
      end
    end

    use RackTest::App
  end
end
