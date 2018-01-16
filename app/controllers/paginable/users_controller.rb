class Paginable::UsersController < ApplicationController
  include Paginable
  # /paginable/users/index/:page
  def index
    authorize User
    paginable_renderise(partial: 'index', scope: current_user.org.users.includes(:roles), locals: { page: params[:page] })
  end
end