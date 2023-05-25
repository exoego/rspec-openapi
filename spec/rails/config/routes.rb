Rails.application.routes.draw do
  mount ::MyEngine::Engine => '/my_engine'

  defaults format: 'json' do
    resources :tables, only: [:index, :show, :create, :update, :destroy]
    resources :images, only: [:index, :show] do
      collection do
        post 'upload'
        post 'upload_nested'
        post 'upload_multiple'
      end
    end
    resources :users,  only: [:show, :create]

    get '/test_block' => ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['A TEST']] }
  end
end
