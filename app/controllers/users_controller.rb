# frozen_string_literal: true

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

    respond_to do |format|
      format.html do
        if current_user.can_super_admin?
          @users = User.includes(:roles).page(1)
        else
          @users = current_user.org.users.includes(:roles).page(1)
        end
      end

      format.csv do
        send_data User.to_csv(current_user.org.users.order(:surname)),
        filename: "users-accounts-#{Date.today}.csv"
      end
    end
  end

  ##
  # GET - Displays the permissions available to the selected user
  # Permissions which the user already has are pre-selected
  # Selecting new permissions and saving calls the admin_update_permissions action
  def admin_grant_permissions
    user = User.find(params[:id])
    authorize user

    # Super admin can grant any Perm, org admins can only grant Perms they
    # themselves have access to
    if current_user.can_super_admin?
      perms = Perm.all
    else
      perms = current_user.perms
    end

    render json: {
      "user" => {
        "id" => user.id,
        "html" => render_to_string(partial: "users/admin_grant_permissions",
                                   locals: { user: user, perms: perms },
                                   formats: [:html])
      }
    }.to_json
  end

  ##
  # POST - updates the permissions for a user
  # redirects to the admin_index action
  # should add validation that the perms given are current perms of the current_user
  def admin_update_permissions
    @user = User.find(params[:id])
    authorize @user
    perms_ids = params[:perm_ids].blank? ? [] : params[:perm_ids].map(&:to_i)
    perms = Perm.where(id: perms_ids)
    privileges_changed = false
    current_user.perms.each do |perm|
      if @user.perms.include? perm
        if ! perms.include? perm
          @user.perms.delete(perm)
          if perm.id == Perm.use_api.id
            @user.remove_token!
          end
          privileges_changed = true
        end
      else
        if perms.include? perm
          @user.perms << perm
          if perm.id == Perm.use_api.id
            @user.keep_or_generate_token!
            privileges_changed = true
          end
        end
      end
    end

    if @user.save
      if privileges_changed
        deliver_if(recipients: @user, key: "users.admin_privileges") do |r|
          UserMailer.admin_privileges(r).deliver_now
        end
      end
      render(json: {
        code: 1,
        msg: success_message(perms.first_or_initialize, _("saved")),
        current_privileges: render_to_string(partial: "users/current_privileges",
                                             locals: { user: @user }, formats: [:html])
        })
    else
      render(json: { code: 0, msg: failure_message(@user, _("updated")) })
    end
  end

  def update_email_preferences
    prefs = params[:prefs]
    authorize User
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
    redirect_to "#{edit_user_registration_path}\#notification-preferences",
                notice: success_message(pref, _("saved"))
  end

  # PUT /users/:id/activate
  # -----------------------------------------------------
  def activate
    authorize current_user

    user = User.find(params[:id])
    if user.present?
      begin
        user.active = !user.active
        user.save!
        render json: {
          code: 1,
          msg: _("Successfully %{action} %{username}'s account.") % {
            action: user.active ? _("activated") : _("deactivated"),
            username: user.name(false)
          }
        }
      rescue Exception
        render json: {
          code: 0,
          msg: _("Unable to %{action} %{username}") % {
            action: user.active ? _("activate") : _("deactivate"),
            username: user.name(false)
          }
        }
      end
    end
  end

  # POST /users/acknowledge_notification
  def acknowledge_notification
    authorize current_user
    @notification = Notification.find(params[:notification_id])
    current_user.acknowledge(@notification)
    render nothing: true
  end

  private

  ##
  # html forms return our boolean values as strings, this converts them to true/false
  def booleanize_hash(node)
    # leaf: convert to boolean and return
    # hash: iterate over leaves
    unless node.is_a?(Hash)
      return node == "true"
    end
    node.each do |key, value|
      node[key] = booleanize_hash(value)
    end
  end

end
