require 'rails_helper'

RSpec.describe 'Tables', type: :request do
  describe '#index' do
    it 'returns a list of tables' do
      get '/tables', params: { page: '1', per: '10' }, headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end

    it 'does not return tables if unauthorized' do
      get '/tables'
      expect(response.status).to eq(401)
    end
  end

  describe '#show' do
    it 'returns a table' do
      get '/tables/1', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end

    it 'does not return a table if unauthorized' do
      get '/tables/1'
      expect(response.status).to eq(401)
    end

    it 'does not return a table if not found' do
      get '/tables/2', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(404)
    end
  end

  describe '#create' do
    it 'returns a table' do
      post '/tables', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
        name: 'k0kubun',
        description: nil,
        database_id: 2,
      }.to_json
      expect(response.status).to eq(201)
    end
  end

  describe '#update' do
    it 'returns a table' do
      patch '/tables/1', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end
  end

  describe '#destroy' do
    it 'returns a table' do
      delete '/tables/1', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end
  end
end
