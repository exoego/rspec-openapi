class PagesController < ApplicationController
  def get
    if params[:head] == '1'
      head :no_content
    else
      render html: '<div>hello</div>'.html_safe
    end
  end
end
