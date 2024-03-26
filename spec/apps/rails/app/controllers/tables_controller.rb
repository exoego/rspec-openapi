class TablesController < ApplicationController
  APIKEY = 'k0kubun'.freeze

  before_action :authenticate

  def index
    response.set_header('X-Cursor', 100)
    if params[:show_columns]
      render json: [find_table('42')]
    else
      render json: [find_table]
    end
  end

  def show
    render json: find_table(params[:id])
  end

  def create
    if params[:name].blank? || params[:name] == 'some_invalid_name'
      render json: { error: 'invalid name parameter' }, status: 422
    else
      render json: find_table, status: 201
    end
  end

  def update
    render json: find_table(params[:id])
  end

  def destroy
    if params[:no_content]
      return head 202
    end

    render json: find_table(params[:id])
  end

  private

  def authenticate
    if request.headers[:authorization] != APIKEY
      render json: { message: 'Unauthorized' }, status: 401
    end
  end

  def find_table(id = nil)
    time = Time.parse('2020-07-17 00:00:00')
    case id
    when '1', nil
      {
        id: 1,
        name: 'access',
        description: 'logs',
        database: {
          id: 2,
          name: 'production',
        },
        null_sample: nil,
        storage_size: 12.3,
        created_at: time.iso8601,
        updated_at: time.iso8601,
      }
    when '42'
      {
        id: 42,
        name: 'access',
        description: 'logs',
        database: {
          id: 4242,
          name: 'production',
        },
        columns: [
          { name: 'id', column_type: 'integer' },
          { name: 'description', column_type: 'varchar' },
        ],
        null_sample: nil,
        storage_size: 12.3,
        created_at: time.iso8601,
        updated_at: time.iso8601,
      }
    else
      raise NotFoundError
    end
  end
end
