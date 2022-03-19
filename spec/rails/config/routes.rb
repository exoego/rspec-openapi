Rails.application.routes.draw do
  mount ::MyEngine::Engine => '/my_engine'

  defaults format: 'json' do
    resources :tables, only: [:index, :show, :create, :update, :destroy]
    resources :images, only: [:show]

    get '/test_block' => ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['A TEST']] }
  end
end
