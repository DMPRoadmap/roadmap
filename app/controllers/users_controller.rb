class UsersController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
  # GET - List of all users for an organisation
  # Displays number of roles[was project_group], name, email, and last sign in
  def admin_index
    authorize User
    @users = current_user.org.users.includes(:roles)
  end

  ##
  # GET - Displays the permissions available to the selected user
  # Permissions which the user already has are pre-selected
  # Selecting new permissions and saving calls the admin_update_permissions action
  def admin_grant_permissions
    @user = User.includes(:perms).find(params[:id])
    authorize @user
    user_perms = current_user.perms
    @perms = user_perms & [Perm::GRANT_PERMISSIONS, Perm::MODIFY_TEMPLATES, Perm::MODIFY_GUIDANCE, Perm::USE_API, Perm::CHANGE_ORG_DETAILS]
  end

  ##
  # POST - updates the permissions for a user
  # redirects to the admin_index action
  # should add validation that the perms given are current perms of the current_user
  def admin_update_permissions
    @user = User.includes(:perms).find(params[:id])
    authorize @user
    perms_ids = params[:perm_ids].blank? ? [] : params[:perm_ids].map(&:to_i)
    perms = Perm.where( id: perms_ids)
    current_user.perms.each do |perm|
      if @user.perms.include? perm
        if ! perms.include? perm
          @user.perms.delete(perm)
          if perm.id == Perm::USE_API.id
            @user.remove_token!
          end
        end
      else
        if perms.include? perm
          @user.perms << perm
          if perm.name == Perm::USE_API.id
            @user.keep_or_generate_token!
          end
        end
      end
    end
    @user.save!
    redirect_to({controller: 'users', action: 'admin_index'}, {notice: I18n.t('helpers.success')})
  end

end
