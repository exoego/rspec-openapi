class SitesController < ApplicationController
  def show
    render json: find_site(params[:name])
  end

  private

  def find_site(name = nil)
    case name
    when 'abc123', nil
      {
        name: name,
      }
    else
      raise NotFoundError
    end
  end
end
