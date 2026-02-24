# frozen_string_literal: true

class EnumTestController < ApplicationController
  def status
    render json: {
      status: 'active',
      message: 'User status retrieved',
    }
  end

  def nested
    render json: {
      group_name: 'Marketing',
      status: 'active',
      user: {
        name: 'John Doe',
        role: 'admin',
      },
    }
  end

  def array_items
    render json: {
      items: [
        { id: 1, name: 'Item 1', status: 'active', priority: 'high' },
        { id: 2, name: 'Item 2', status: 'inactive', priority: 'low' },
      ],
    }
  end

  def create
    render json: {
      id: 1,
      action_type: 'create',
      status: 'pending',
    }, status: 201
  end

  def deeply_nested
    render json: {
      organization: {
        name: 'Acme Corp',
        settings: {
          visibility: 'public',
          access_level: 'standard',
        },
      },
    }
  end
end
