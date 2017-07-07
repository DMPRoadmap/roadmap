class UsersController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
  # GET - List of all users for an organisation
  # Displays number of roles[was project_group], name, email, and last sign in
  def admin_index
    authorize User
    # Sets the user to the currently logged in user if it is undefined
#    @user = current_user if @user.nil?
#    @users = @user.org.users.includes(:roles)
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
    @perms = user_perms & [Perm.grant_permissions, Perm.modify_templates, Perm.modify_guidance, Perm.use_api, Perm.change_org_details]
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
          if perm.id == Perm.use_api.id
            @user.remove_token!
          end
        end
      else
        if perms.include? perm
          @user.perms << perm
          if perm.name == Perm.use_api.id
            @user.keep_or_generate_token!
          end
        end
      end
    end

    if @user.save!
      redirect_to({controller: 'users', action: 'admin_index'}, {notice: success_message(_('permissions'), _('saved'))})  # helpers.success key does not exist, replaced with a generic string
    else
      flash[:alert] = failed_update_error(@user, _('user'))
    end
  end

  def update_preferences
    @user = User.find(params[:user_id])
    prefs = params[:prefs]
    authorize @user, :update?
    # Set all preferences to false
    @user.prefs.each do |key, value|
      value.each_key do |k|
        @user.prefs[key][k] = false
      end
    end

    # Sets the preferences the user wants to true
    if prefs
      prefs.each_key do |key|
        prefs[key].each_key do |k|
          @user.prefs[key.to_sym][k.to_sym] = true
        end
      end
    end
    @tab = params[:tab]
    @user.save
    redirect_to edit_user_registration_path(tab: @tab), notice: success_message(_('preferences'), _('saved'))
  end

end
