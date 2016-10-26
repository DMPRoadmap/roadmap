class TokenPermissionTypesController < ApplicationController
  def index
    authorize TokenPermissionType
    @user = current_user
    @token_types = @user.organisation.token_permission_types
    respond_to do |format|
      format.html
    end
  end
end