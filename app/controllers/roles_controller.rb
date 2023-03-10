# frozen_string_literal: true

# Controller that handles adding/updating/removing collaborators from a plan
class RolesController < ApplicationController
  include ConditionalUserMailer
  respond_to :html

  after_action :verify_authorized

  # POST /roles
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    registered = true

    plan = Plan.find(role_params[:plan_id])
    @role = Role.new(plan: plan, access: role_params[:access])
    authorize @role

    message = ''
    if role_params[:user].present? &&
       role_params[:user].key?(:email) &&
       role_params[:user][:email].present? && plan.present?

      if @role.plan.owner.present? && @role.plan.owner.email == role_params[:user][:email]
        flash[:notice] = format(_('Cannot share plan with %{email} since that email matches
                                   with the owner of the plan.'),
                                email: role_params[:user][:email])
      else
        user = User.where_case_insensitive('email', role_params[:user][:email]).first
        if user.present? &&
           Role.where(plan: @role.plan, user: user, active: true)
               .count
               .positive? # role already exists

          flash[:notice] = format(_('Plan is already shared with %{email}.'),
                                  email: role_params[:user][:email])
        else
          # rubocop:disable Metrics/BlockNesting
          if user.nil?
            registered = false
            User.invite!({ email: role_params[:user][:email],
                           firstname: _('First Name'),
                           surname: _('Surname'),
                           org: current_user.org },
                         current_user)
            message = format(_('Invitation to %{email} issued successfully.'),
                             email: role_params[:user][:email])
            user = User.where_case_insensitive('email', role_params[:user][:email]).first
          end

          message += format(_('Plan shared with %{email}.'), email: user.email)
          @role.user = user

          if @role.save
            if registered
              deliver_if(recipients: user, key: 'users.added_as_coowner') do |r|
                UserMailer.sharing_notification(@role, r, inviter: current_user)
                          .deliver_now
              end
            end
            flash[:notice] = message
          else
            flash[:alert] = _('You must provide a valid email address and select a permission
                               level.')
          end
          # rubocop:enable Metrics/BlockNesting
        end
      end
    else
      flash[:alert] = _('Please enter an email address')
    end
    redirect_to controller: 'plans', action: 'share', id: @role.plan.id
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # PUT /roles/:id
  # rubocop:disable Metrics/AbcSize
  def update
    @role = Role.find(params[:id])
    authorize @role

    if @role.update(access: role_params[:access])
      deliver_if(recipients: @role.user, key: 'users.added_as_coowner') do |_r|
        UserMailer.permissions_change_notification(@role, current_user).deliver_now
      end
      render json: {
        code: 1,
        msg: format(_('Successfully changed the permissions for %{email}. They have been
                       notified via email.'), email: @role.user.email)
      }
    else
      render json: { code: 0, msg: flash[:alert] }
    end
  end
  # rubocop:enable Metrics/AbcSize

  # DELETE /roles/:id
  # rubocop:disable Metrics/AbcSize
  def destroy
    @role = Role.find(params[:id])
    authorize @role
    user = @role.user
    plan = @role.plan
    @role.destroy
    flash[:notice] = _('Access removed')
    deliver_if(recipients: user, key: 'users.added_as_coowner') do |_r|
      UserMailer.plan_access_removed(user, plan, current_user).deliver_now
    end
    redirect_to controller: 'plans', action: 'share', id: @role.plan.id
  end
  # rubocop:enable Metrics/AbcSize

  # This function makes user's role on a plan inactive
  # i.e. "removes" this from their plans
  # PUT /roles/:id/deactivate
  def deactivate
    role = Role.find(params[:id])
    authorize role
    if role.deactivate!
      flash[:notice] = _('Plan removed')
    else
      flash[:alert] = _('Unable to remove the plan')
    end
    redirect_to(plans_path)
  end

  private

  def role_params
    params.require(:role).permit(:plan_id, :access, user: %i[email])
  end
end
