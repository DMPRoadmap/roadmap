class OrganisationUsersController < ApplicationController

    def admin_index
        if user_signed_in? && current_user.is_org_admin? then
            # find excluded user_id's
            excluded_ids = params[:user_ids]
            excluded_ids.each do |user_id|
                User.find(user_id).remove_token
            end
            # remove their api_tokens
            # find included user id's
            params[:user_ids].each do |user_id|
                User.find(user_id).keep_or_generate_token
            end
            # keep_or_generate_token
            respond_to do |format|
                format.html # index.html.erb
                format.json { render json: @organisation_users }
            end
        else
            render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
        end
    end

end