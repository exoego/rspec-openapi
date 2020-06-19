class TablesController < ApplicationController
  def index
    render json: [table]
  end

  private

  def table
    {
      id: 1,
      name: 'access',
      description: nil,
      database: {
        id: 2,
        name: 'production',
      },
      created_at: Time.now,
      updated_at: Time.now,
    }
  end
end
