require 'spec_helper'

RSpec.describe 'Tables', type: :request do
  describe '#index' do
    it 'returns a list of tables' do
      get '/tables'
      expect(response.status).to eq(200)
    end
  end
end
