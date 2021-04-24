Rails.application.routes.draw do
  defaults format: 'json' do
    resources :tables, only: [:index, :show, :create, :update, :destroy]
    resources :images, only: [:show]
  end
end
