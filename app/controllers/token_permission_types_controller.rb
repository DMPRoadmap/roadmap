class TokenPermissionTypesController < ApplicationController


    def index
        if user_signed_in? && current_user.organisation.token_permission_types.count > 0
            @user = current_user
            respond_to do |format|
                format.html
            end
        else
            render(file: File.join(Rails.root, 'public/403.html'),status: 403, layout: false)
        end
    end

end