class TokenPermissionTypesController < ApplicationController


    def index
      authorize TokenPermissionType
      @user = current_user
      respond_to do |format|
        format.html
      end
    end

end