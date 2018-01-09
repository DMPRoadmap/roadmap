class Paginable::UsersController < ApplicationController
  include Paginable
  # /paginable/users/index/:page
  def index
    authorize User
    users = params[:page] == 'ALL' ?
      current_user.org.users.includes(:roles) :
      current_user.org.users.includes(:roles).page(params[:page])
    paginable_renderise(partial: 'index', scope: users)
  end
end