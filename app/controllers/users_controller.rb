# frozen_string_literal: true

# Controller that handles Admin operations for managing users
class UsersController < ApplicationController
  helper PaginableHelper
  helper PermsHelper
  include ConditionalUserMailer
  after_action :verify_authorized
  respond_to :html

  ##
  # GET - List of all users for an organisation
  # Displays number of roles[was project_group], name, email, and last sign in
  # rubocop:disable Metrics/AbcSize
  def admin_index
    authorize User

    respond_to do |format|
      format.html do
        @clicked_through = params[:click_through].present?
        @filter_admin = false

        @users = if current_user.can_super_admin?
                   User.includes(:department, :org, :perms, :roles, :identifiers).page(1)
                 else
                   current_user.org.users
                               .includes(:department, :org, :perms, :roles, :identifiers)
                               .page(1)
                 end
      end

      format.csv do
        send_data User.to_csv(current_user.org.users.order(:surname)),
                  filename: "users-accounts-#{Date.today}.csv"
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  ##
  # GET - Displays the permissions available to the selected user
  # Permissions which the user already has are pre-selected
  # Selecting new permissions and saving calls the admin_update_permissions action
  def admin_grant_permissions
    user = User.find(params[:id])
    authorize user

    # Super admin can grant any Perm, org admins can only grant Perms they
    # themselves have access to
    perms = if current_user.can_super_admin?
              Perm.all
            else
              current_user.perms
            end

    render json: {
      'user' => {
        'id' => user.id,
        'html' => render_to_string(partial: 'users/admin_grant_permissions',
                                   locals: { user: user, perms: perms },
                                   formats: [:html])
      }
    }.to_json
  end

  ##
  # POST - updates the permissions for a user
  # redirects to the admin_index action
  # should add validation that the perms given are current perms of the current_user
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def admin_update_permissions
    @user = User.find(params[:id])
    authorize @user

    perms_ids = permission_params[:perm_ids].blank? ? [] : permission_params[:perm_ids].map(&:to_i)
    perms = Perm.where(id: perms_ids)
    privileges_changed = false
    current_user.perms.each do |perm|
      if @user.perms.include? perm
        unless perms.include? perm
          @user.perms.delete(perm)
          @user.remove_token! if perm.id == Perm.use_api.id
          privileges_changed = true
        end
      elsif perms.include? perm
        @user.perms << perm
        if perm.id == Perm.use_api.id
          @user.keep_or_generate_token!
          privileges_changed = true
        end
      end
    end

    if @user.save
      if privileges_changed
        deliver_if(recipients: @user, key: 'users.admin_privileges') do |r|
          UserMailer.admin_privileges(r).deliver_now
        end
      end
      render(json: {
               code: 1,
               msg: success_message(perms.first_or_initialize, _('saved')),
               current_privileges: render_to_string(partial: 'users/current_privileges',
                                                    locals: { user: @user }, formats: [:html])
             })
    else
      render(json: { code: 0, msg: failure_message(@user, _('updated')) })
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # PUT /users/:id/update_email_preferences
  # rubocop:disable Metrics/AbcSize
  def update_email_preferences
    prefs = preference_params
    authorize User
    pref = current_user.pref
    # does user not have prefs?
    if pref.blank?
      pref = Pref.new
      pref.settings = {}
      pref.user = current_user
    end
    pref.settings['email'] = booleanize_hash(prefs['prefs'])
    pref.save

    # Include active tab in redirect path
    redirect_to "#{edit_user_registration_path}#notification-preferences",
                notice: success_message(pref, _('saved'))
  end
  # rubocop:enable Metrics/AbcSize

  # PUT /users/:id/activate
  # -----------------------------------------------------
  # rubocop:disable Metrics/AbcSize
  def activate
    authorize current_user

    user = User.find(params[:id])
    return unless user.present?

    begin
      user.active = !user.active
      user.save!
      render json: {
        code: 1,
        msg: format(_("Successfully %{action} %{username}'s account."),
                    action: user.active ? _('activated') : _('deactivated'),
                    username: user.name(false))
      }
    rescue StandardError
      render json: {
        code: 0,
        msg: format(_('Unable to %{action} %{username}'),
                    action: user.active ? _('activate') : _('deactivate'),
                    username: user.name(false))
      }
    end
  end
  # rubocop:enable Metrics/AbcSize

  # POST /users/acknowledge_notification
  def acknowledge_notification
    authorize current_user
    @notification = Notification.find(notification_params[:notification_id])
    current_user.acknowledge(@notification)
    render body: nil
  end

  # GET /users/:id/refresh_token (accessed via JSON call from profile page)
  def refresh_token
    authorize current_user
    original = current_user.api_token
    current_user.generate_token!
    @success = current_user.api_token != original
  end

  private

  def permission_params
    params.permit(:super_admin_privileges, :org_admin_privileges, perm_ids: [])
  end

  def notification_params
    params.permit(:notification_id)
  end

  def preference_params
    params.require(:user).permit(
      prefs: [
        users: %i[new_comment
                  added_as_coowner
                  admin_privileges
                  feedback_requested
                  feedback_provided],
        owners_and_coowners: %i[visibility_changed]
      ]
    )
  end

  ##
  # html forms return our boolean values as strings, this converts them to true/false
  def booleanize_hash(node)
    # leaf: convert to boolean and return
    # hash: iterate over leaves
    return node == 'true' unless node.is_a?(ActionController::Parameters)

    newnode = {}
    node.each do |key, value|
      newnode[key] = booleanize_hash(value)
    end
    newnode
  end
end
