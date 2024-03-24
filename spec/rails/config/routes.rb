Rails.application.routes.draw do
  mount ::MyEngine::Engine => '/my_engine'

  get '/my_engine/test' => ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['ANOTHER TEST']] }

  get '/pages' => 'pages#get'

  defaults format: 'json' do
    resources :tables, only: [:index, :show, :create, :update, :destroy]
    resources :images, only: [:index, :show] do
      collection do
        post 'upload'
        post 'upload_nested'
        post 'upload_multiple'
        post 'upload_multiple_nested'
      end
    end
    resources :users,  only: [:show, :create] do
      get 'active'
    end

    get '/test_block' => ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['A TEST']] }

    get '/secret_items' => 'secret_items#index'

    get '/additional_properties' => 'additional_properties#index'

    scope :admin do
      namespace :masters do
        resources :extensions, only: [:index, :create]
      end
    end
  end
end
