# frozen_string_literal: true

class RolesController < ApplicationController

  include ConditionalUserMailer
  respond_to :html
  after_action :verify_authorized

  def create
    registered = true
    @role = Role.new(role_params)
    authorize @role

    plan = Plan.find(role_params[:plan_id])

    message = ""
    if params[:user].present? && plan.present?
      if @role.plan.owner.present? && @role.plan.owner.email == params[:user]
        # rubocop:disable Metrics/LineLength
        flash[:notice] = _("Cannot share plan with %{email} since that email matches with the owner of the plan.") % {
          email: params[:user]
        }
        # rubocop:enable Metrics/LineLength
      else
        user = User.where_case_insensitive("email", params[:user]).first
        if Role.find_by(plan: @role.plan, user: user) # role already exists
          flash[:notice] = _("Plan is already shared with %{email}.") % {
            email: params[:user]
          }
        else
          if user.nil?
            registered = false
            User.invite!({email:     params[:user],
                        firstname:  _("First Name"),
                        surname:    _("Surname"),
                        org:        current_user.org },
                        current_user )
            message = _("Invitation to %{email} issued successfully.") % {
              email: params[:user]
            }
            user = User.where_case_insensitive("email", params[:user]).first
          end
          message += _("Plan shared with %{email}.") % {
            email: user.email
          }
          @role.user = user
          if @role.save
            if registered
              deliver_if(recipients: user, key: "users.added_as_coowner") do |r|
                UserMailer.sharing_notification(@role, r, inviter: current_user)
                          .deliver_now
              end
            end
            flash[:notice] = message
          else
            # rubocop:disable Metrics/LineLength
            flash[:alert] = _("You must provide a valid email address and select a permission level.")
            # rubocop:enable Metrics/LineLength
          end
        end
      end
    else
      flash[:alert] = _("Please enter an email address")
    end
    redirect_to controller: "plans", action: "share", id: @role.plan.id
  end


  def update
    @role = Role.find(params[:id])
    authorize @role

    if @role.update_attributes(access: role_params[:access])
      deliver_if(recipients: @role.user, key: "users.added_as_coowner") do |r|
        UserMailer.permissions_change_notification(@role, current_user).deliver_now
      end
      # rubocop:disable Metrics/LineLength
      render json: {
        code: 1,
        msg: _("Successfully changed the permissions for %{email}. They have been notified via email.") % { email: @role.user.email }
      }
      # rubocop:enable Metrics/LineLength
    else
      render json: { code: 0, msg: flash[:alert] }
    end
  end

  def destroy
    @role = Role.find(params[:id])
    authorize @role
    user = @role.user
    plan = @role.plan
    @role.destroy
    flash[:notice] = _("Access removed")
    deliver_if(recipients: user, key: "users.added_as_coowner") do |r|
      UserMailer.plan_access_removed(user, plan, current_user).deliver_now
    end
    redirect_to controller: "plans", action: "share", id: @role.plan.id
  end

  # This function makes user's role on a plan inactive
  # i.e. "removes" this from their plans
  def deactivate
    role = Role.find(params[:id])
    authorize role
    if role.deactivate!
      flash[:notice] = _("Plan removed")
    else
      flash[:alert] = _("Unable to remove the plan")
    end
    redirect_to(plans_path)
  end

  private

  def role_params
    params.require(:role).permit(:plan_id, :access)
  end

end
