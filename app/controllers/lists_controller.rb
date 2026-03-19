class ListsController < ApplicationController
  # GET /
  # Creates a new list and redirects to its shareable URL.
  def index
    list = List.create!
    redirect_to show_list_path(token: list.token)
  end

  # GET /:token
  def show
    @list = List.find_by_token(params[:token])
    redirect_to root_path unless @list
  end
end
