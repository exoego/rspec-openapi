# frozen_string_literal: true

MyEngine::Engine.routes.draw do
  get '/eng_route' => ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['AN ENGINE TEST']] }
end
