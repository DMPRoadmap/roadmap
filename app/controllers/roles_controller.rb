class RolesController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  def create
    @role = Role.new(role_params)
    authorize @role
    access_level = params[:role][:access_level].to_i
    set_access_level(access_level)
    if params[:user].present?
      message = _('User added to project')
      user = User.find_by(email: params[:user])
      if user.nil?
        User.invite!(email: params[:user])
        message = _('Invitation issued successfully.')
        user = User.find_by(email: params[:user])
      end
      @role.user = user
      if @role.save
        UserMailer.sharing_notification(@role).deliver
        flash[:notice] = message
      else
        flash[:notice] = generate_error_notice(@role, _('role'))
      end
    else
      flash[:notice] = _('Please enter an email address')
    end
    redirect_to controller: 'plans', action: 'share', id: @role.plan.id
  end


  def update
    @role = Role.find(params[:id])
    authorize @role
    access_level = params[:role][:access_level].to_i
    set_access_level(access_level)
    if @role.update_attributes(role_params)
      flash[:notice] = _('Sharing details successfully updated.')
      UserMailer.permissions_change_notification(@role).deliver
      redirect_to controller: 'plans', action: 'share', id: @role.plan.id
    else
      flash[:notice] = generate_error_notice(@role, _('role'))
      render action: "edit"
    end
  end

  def destroy
    @role = Role.find(params[:id])
    authorize @role
    user = @role.user
    plan = @role.plan
    @role.destroy
    flash[:notice] = _('Access removed')
    UserMailer.project_access_removed_notification(user, plan).deliver
    redirect_to controller: 'plans', action: 'share', id: @role.plan.id
  end

  private

  def role_params
    params.require(:role).permit(:plan_id)
  end

  def set_access_level(access_level)
    if access_level >= 1
      @role.commenter = true
    else
      @role.commenter = false
    end
    if access_level >= 2
      @role.editor = true
    else
      @role.editor = false
    end
    if access_level >= 3
      @role.administrator = true
    else
      @role.administrator = false
    end
  end

end