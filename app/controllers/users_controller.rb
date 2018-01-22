class UsersController < ApplicationController
  helper PaginableHelper
  helper PermsHelper
  include ConditionalUserMailer
  after_action :verify_authorized
  respond_to :html

  ##
  # GET - List of all users for an organisation
  # Displays number of roles[was project_group], name, email, and last sign in
  def admin_index
    authorize User
    @users = current_user.org.users.includes(:roles).page(1)
  end

  ##
  # GET - Displays the permissions available to the selected user
  # Permissions which the user already has are pre-selected
  # Selecting new permissions and saving calls the admin_update_permissions action
  def admin_grant_permissions
    @user = User.includes(:perms, :roles).find(params[:id])
    authorize @user
    user_perms = current_user.perms
    @perms = user_perms & [Perm.grant_permissions, Perm.modify_templates, Perm.modify_guidance, 
                           Perm.use_api, Perm.change_org_details, Perm.add_orgs, 
                           Perm.change_affiliation, Perm.grant_api]
    render json: {
      "user" => {
        "id" => @user.id,
        "html" => render_to_string(partial: 'users/admin_grant_permissions', 
                                   locals: { user: @user, perms: @perms }, 
                                   formats: [:html])
      }
    }.to_json
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
          if perm.id == Perm.use_api.id
            @user.keep_or_generate_token!
          end
        end
      end
    end

    if @user.save!
      deliver_if(recipients: @user, key: 'users.admin_privileges') do |r|
        UserMailer.admin_privileges(r).deliver_now
      end
      redirect_to({controller: 'users', action: 'admin_index'}, {notice: success_message(_('permissions'), _('saved'))})  # helpers.success key does not exist, replaced with a generic string
    else
      flash[:alert] = failed_update_error(@user, _('user'))
    end
  end

  def update_email_preferences
    prefs = params[:prefs]
    authorize current_user, :update?
    pref = current_user.pref
    # does user not have prefs?
    if pref.blank?
      pref = Pref.new
      pref.settings = {}
      pref.user = current_user
    end
    pref.settings[:email] = booleanize_hash(prefs)
    pref.save

    # Include active tab in redirect path
    redirect_to "#{edit_user_registration_path}\#notification-preferences", notice: success_message(_('preferences'), _('saved'))
  end

  # PUT /users/:id/org_swap
  # -----------------------------------------------------
  def org_swap
    # Allows the user to swap their org affiliation on the fly
    authorize current_user
    org = Org.find(org_swap_params[:org_id])
    if org.present?
      current_user.org = org
      if current_user.save!
        redirect_to request.referer, notice: _('Your organisation affiliation has been changed. You may now edit templates for %{org_name}.') % {org_name: current_user.org.name}
      else
        redirect_to request.referer, alert: _('Unable to change your organisation affiliation at this time.')
      end
    else
      redirect_to request.referer, alert: _('Unknown organisation.')
    end
  end
  
  private
  def org_swap_params
    params.require(:user).permit(:org_id, :org_name)
  end
  
  ##
  # html forms return our boolean values as strings, this converts them to true/false
  def booleanize_hash(node)
    #leaf: convert to boolean and return
    #hash: iterate over leaves
    unless node.is_a?(Hash)
      return node == "true"
    end
    node.each do |key, value|
      node[key] = booleanize_hash(value)
    end
  end

end
