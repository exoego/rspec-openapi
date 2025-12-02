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
    end

    scope :admin do
      namespace :masters do
        resources :extensions, only: [:index, :create]
      end
    end
  end
end
