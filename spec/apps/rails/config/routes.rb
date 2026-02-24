Rails.application.routes.draw do
  mount ::MyEngine::Engine => '/my_engine'
  mount ::RackTest::App.new, at: '/rack'

  get '/my_engine/test' => ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['ANOTHER TEST']] }

  defaults format: :html do
    get '/pages' => 'pages#get'
  end

  defaults format: 'json' do
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

    # Test route for nested arrays (key_transformer coverage)
    get '/nested_arrays_test' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"items":[{"name":"first","tags":["a","b","c"]},{"name":"second","tags":["x","y","z"]}],"matrix":[[1,2],[3,4]]}']] }

    # Enum test routes
    get '/enum_test/status' => 'enum_test#status'
    get '/enum_test/nested' => 'enum_test#nested'
    get '/enum_test/array_items' => 'enum_test#array_items'
    post '/enum_test' => 'enum_test#create'
    get '/enum_test/deeply_nested' => 'enum_test#deeply_nested'

    # Test route for invalid example_mode error handling
    get '/invalid_example_mode' => ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']] }
  end
end
