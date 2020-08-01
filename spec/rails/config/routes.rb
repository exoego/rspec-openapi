Rails.application.routes.draw do
  defaults format: 'json' do
    resources :tables, only: [:index, :show, :create, :update, :destroy]
  end
end
