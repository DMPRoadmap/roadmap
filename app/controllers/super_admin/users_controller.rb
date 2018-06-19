module SuperAdmin
  class UsersController < ApplicationController

    after_action :verify_authorized

    def edit
      user = User.find(params[:id])
      if user.present?
        authorize user
        languages = Language.sorted_by_abbreviation
        orgs = Org.where(parent_id: nil).order("name")
        identifier_schemes = IdentifierScheme.where(active: true).order(:name)
      
        render 'super_admin/users/edit', 
               locals: { user: user, 
                         languages: languages,
                         orgs: orgs, 
                         identifier_schemes: identifier_schemes, 
                         default_org: user.org }
      else
        redirect_to admin_index_users_path, alert: _('User not found.')
      end
    end
   
    def update
      user = User.find(params[:id])
      if user.present?
        authorize user
        topic = _('%{username}\'s profile') % { username: user.name(false) }
        if user.update_attributes(user_params)
          redirect_to edit_super_admin_user_path(user), 
                      notice: _('Successfully updated %{username}') % { username: topic }
        else
          redirect_to edit_super_admin_user_path(user), 
                      alert: _('Unable to update %{username}') % { username: topic }
        end
      else
        redirect_to edit_super_admin_user_path(user), alert: _('User not found.')
      end
    end
     
    private
      def user_params
        params.require(:user).permit(:email, :firstname, :surname, :org_id, :language_id, :other_organisation)
      end
  end
end