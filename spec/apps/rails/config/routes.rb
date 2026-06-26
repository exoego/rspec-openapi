Rails.application.routes.draw do
  mount ::MyEngine::Engine => '/my_engine'
  mount ::RackTest::App.new, at: '/rack'

  get '/my_engine/test' => ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['ANOTHER TEST']] }

  defaults format: :html do
    get '/pages' => 'pages#get'
  end

  defaults format: 'json' do
    get '/override_probe' => 'tables#override_probe'
    resources :sites, param: :name, only: [:show]
    resources :tables, only: [:index, :show, :create, :update, :destroy]
    resources :images, only: [:index, :show] do
      collection do
        post 'upload'
        post 'upload_nested'
        post 'upload_multiple'
        post 'upload_multiple_nested'
      end
    end
    resources :users, only: [:show, :create] do
      get 'active'
    end

    get '/test_block' => ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['A TEST']] }

    get '/secret_items' => 'secret_items#index'

    get '/additional_properties' => 'additional_properties#index'
    get '/invalid_responses' => 'invalid_responses#show'
    resources :array_hashes, only: [] do
      get :nullable, on: :collection
      get :non_nullable, on: :collection
      get :nested, on: :collection
      get :empty_array, on: :collection
      get :single_item, on: :collection
      get :non_hash_items, on: :collection
      get :nested_arrays, on: :collection
      get :nested_objects, on: :collection
      get :mixed_types_nested, on: :collection
      get :multiple_one_of_test, on: :collection
      get :nested_arrays_across_items, on: :collection
      get :regression_arrays_of_arrays_divergent, on: :collection
      get :regression_nested_array_empty_then_populated, on: :collection
    end

    scope :admin do
      namespace :masters do
        resources :extensions, only: [:index, :create]
      end
    end

    # Test routes for example_mode feature testing
    get '/example_mode_none' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']] }
    get '/example_mode_single' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"single"}']] }
    get '/example_mode_multiple' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"multiple"}']] }
    get '/example_mode_mixed' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"mixed"}']] }
    get '/example_mode_inherit' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"inherit"}']] }
    get '/example_mode_override_single' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"override_single"}']] }
    get '/example_mode_override_none' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"override_none"}']] }
    get '/example_mode_disabled' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"disabled"}']] }
    get '/example_mode_disabled_single' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"disabled_single"}']] }
    get '/example_mode_disabled_multiple' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"disabled_multiple"}']] }
    get '/example_mode_disabled_none' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"disabled_none"}']] }
    post '/tags' => ->(_env) { [201, { 'Content-Type' => 'application/json' }, ['{"created":true}']] }
    get '/custom_example_key' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"data":"custom_key"}']] }
    get '/custom_example_name' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"data":"custom_name"}']] }
    get '/example_summary_disabled' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"data":"no_summary"}']] }
    get '/empty_example_name' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"data":"empty_name"}']] }

    # Streaming media type: `itemSchema` on 3.2, a string schema on 3.0/3.1.
    get '/stream' => ->(_env) {
      body = %({"id":1,"name":"a"}\n{"id":2,"name":null}\n{"id":3}\n)
      [200, { 'Content-Type' => 'application/x-ndjson' }, [body]]
    }

    # JSON Text Sequences (RFC 7464): records separated by the RS byte (\x1e).
    # The leading separator yields an empty leading chunk that StreamParser skips.
    get '/stream_json_seq' => ->(_env) {
      body = %(\x1e{"id":1,"name":"a"}\n\x1e{"id":2,"name":null}\n\x1e{"id":3}\n)
      [200, { 'Content-Type' => 'application/json-seq' }, [body]]
    }

    # Server-Sent Events: blank-line separated events whose `data:` lines hold the
    # JSON. Includes a leading blank line, a non-`data:` field line, and a
    # non-JSON event so the empty-buffer, ignored-line and unparseable-chunk paths
    # are all exercised. Ends without a trailing blank line (last event flushed
    # after the loop).
    get '/stream_sse' => ->(_env) {
      body = +''
      body << %(\n)
      body << %(event: message\n)
      body << %(data: {"id":1,"name":"a"}\n\n)
      body << %(data: {"id":2,"name":null}\n\n)
      body << %(data: not-json\n\n)
      body << %(data: {"id":3}\n)
      [200, { 'Content-Type' => 'text/event-stream' }, [body]]
    }

    # SSE that ends WITH a trailing blank line, so the after-loop flush sees an
    # empty buffer (the counterpart of /stream_sse).
    get '/stream_sse_blank_end' => ->(_env) {
      [200, { 'Content-Type' => 'text/event-stream' }, [%(data: {"id":1}\n\n)]]
    }

    # Sequential media type whose body has no parseable items: every line is
    # blank, so StreamParser yields nothing and the builder falls back to a
    # plain string schema instead of itemSchema.
    get '/stream_empty' => ->(_env) {
      [200, { 'Content-Type' => 'application/x-ndjson' }, [%(\n\n)]]
    }

    # Minimal endpoint used by the hand-edited-document round-trip spec.
    get '/roundtrip' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"ok":true}']] }

    # QUERY / additionalOperations demo. Non-standard-verb routing is verified on
    # Rails 7.1+, so these routes are defined only there.
    if Gem::Version.new(Rails::VERSION::STRING) >= Gem::Version.new('7.1')
      match '/aop_search' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"results":[]}']] },
            via: :query
      match '/aop_resource' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"copied":true}']] },
            via: :copy
    end

    # Test routes for requestBody multi-example feature (#312)
    post '/example_mode_multiple_request_body' => lambda { |env|
      status = (env['HTTP_X_TEST_STATUS'] || '200').to_i
      [status, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']]
    }
    post '/example_mode_request_body_mixed' => ->(_env) { [201, { 'Content-Type' => 'application/json' }, ['{"created":true}']] }
    post '/example_mode_request_only_multi' => ->(_env) { [201, { 'Content-Type' => 'application/json' }, ['{"created":true}']] }
    post '/example_mode_request_body_none' => ->(_env) { [201, { 'Content-Type' => 'application/json' }, ['{"created":true}']] }

    # Test route for nested arrays (key_transformer coverage)
    get '/nested_arrays_test' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"items":[{"name":"first","tags":["a","b","c"]},{"name":"second","tags":["x","y","z"]}],"matrix":[[1,2],[3,4]]}']] }

    # Enum test routes
    get '/enum_test/status' => 'enum_test#status'
    get '/enum_test/nested' => 'enum_test#nested'
    get '/enum_test/array_items' => 'enum_test#array_items'
    post '/enum_test' => 'enum_test#create'
    get '/enum_test/deeply_nested' => 'enum_test#deeply_nested'

    # Dynamic-key (additionalProperties) test routes
    get '/dynamic_keys_test/wrapped' => 'dynamic_keys_test#wrapped'
    get '/dynamic_keys_test/root' => 'dynamic_keys_test#root'
    get '/dynamic_keys_test/complex_values' => 'dynamic_keys_test#complex_values'
    post '/dynamic_keys_test' => 'dynamic_keys_test#create'
    get '/dynamic_keys_test/closed' => 'dynamic_keys_test#closed'
    get '/dynamic_keys_test/hybrid' => 'dynamic_keys_test#hybrid'
    post '/dynamic_keys_test/respond_with_dynamic' => 'dynamic_keys_test#respond_with_dynamic'
    get '/dynamic_keys_test/deeply_nested' => 'dynamic_keys_test#deeply_nested'
    get '/dynamic_keys_test/with_enum' => 'dynamic_keys_test#with_enum'

    # Test routes for description preservation with example_mode :none
    get '/description_preserve_test' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']] }
    get '/description_overwrite_test' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']] }
    get '/description_mixed_test' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']] }

    # Test route for invalid example_mode error handling
    get '/invalid_example_mode' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']] }
  end
end
