class TokenPermissionTypesController < ApplicationController


    def index
      logger.debug "#{current_user}"
      authorize TokenPermissionType.first
      @user = current_user
      respond_to do |format|
        format.html
      end
    end

end