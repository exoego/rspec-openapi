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

    get '/test_block', to: ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['A TEST']] }

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
