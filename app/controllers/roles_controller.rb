class RolesController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  def create
    @role = Role.new(role_params)
    authorize @role
    
    @role.access_level = role_params[:access_level].to_i
    if role_params[:email].present?
      message = _('User added to project')
      if @role.save
        if @role.user.nil? then
          if User.find_by_email(role_params[:email]).nil? then
            User.invite!(email: role_params[:email])
            message = _('Invitation issued successfully.')
            @role.user = User.find_by_email(role_params[:email])
            @role.save
          else
            @role.user = User.find_by_email(role_params[:email])
            @role.save
            UserMailer.sharing_notification(@role).deliver
          end
        else
          UserMailer.sharing_notification(@role).deliver
        end
        redirect_to share_plan_path(@role.plan), notice: message
      else
        redirect_to share_plan_path(@role.plan), notice: generate_error_notice(@role)
      end
    else
      redirect_to share_plan_path(@role.plan), _('Please enter an email address')
    end
  end

  def update
    @role = Role.find(params[:id])
    authorize @role
    @role.access_level = role_params[:access_level].to_i
    if @role.update_attributes(role_params)
      UserMailer.permissions_change_notification(@role).deliver
      redirect_to share_plan_path(@role.plan), notice: _('Sharing details successfully updated.')
    else
      redirect_to share_plan_path(@role.plan), notice: generate_error_notice(@role)
    end
  end

  def destroy
    @role = Role.find(params[:id])
    authorize @role
    user = @role.user
    plan = @role.plan
    @role.destroy

    UserMailer.project_access_removed_notification(user, plan).deliver
    redirect_to controller: 'plans', action: 'share', id: @role.plan.slug
    redirect_to share_plan_path(@role.plan), notice: _('Access removed')
  end
  
  private
    def role_params
      params.require(:role).permit(:plan_id, :access_level, user: [:email])
    end
end