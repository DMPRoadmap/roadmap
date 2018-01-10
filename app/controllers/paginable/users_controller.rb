class Paginable::UsersController < ApplicationController
  include Paginable
  # /paginable/users/index/:page
  def index
    authorize User
    users = current_user.org.users.includes(:roles)
    if params[:search].present?
      users = users.search(params[:search])
      users = params[:page] == 'ALL' ? users.page(1) : users.page(params[:page])
    else
      users = params[:page] == 'ALL' ? users : users.page(params[:page])
    end
    paginable_renderise(partial: 'index', scope: users)
  end
end