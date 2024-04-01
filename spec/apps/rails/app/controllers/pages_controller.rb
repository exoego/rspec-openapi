class PagesController < ApplicationController
  def get
    if params[:head] == '1'
      head :no_content
    else
      render html: '<!DOCTYPE html><html lang="en"><head><title>Hello</title></head><body>Hello</body></html>'.html_safe
    end
  end
end
