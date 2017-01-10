class TokenPermissionTypesController < ApplicationController
  respond_to :html

  ##
  # GET - Lists all TokenPermissionTypes available to the user
  # also lists their description
  def index
    authorize TokenPermissionType
    @user = current_user
    @token_types = @user.org.token_permission_types
  end
end