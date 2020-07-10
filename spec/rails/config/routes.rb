Rails.application.routes.draw do
  resources :tables, only: [:index, :show, :create, :update, :destroy]
end
