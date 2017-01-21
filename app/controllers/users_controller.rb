class UsersController < ApplicationController
  after_action :verify_authorized

  def admin_index
    authorize User
    
    @users = current_user.organisation.users.includes(:project_groups)
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def admin_grant_permissions
    @user = User.includes(:roles).find(params[:id])
    authorize @user
    user_roles = current_user.roles
    @roles = user_roles & Role.where(name: [constant("roles.change_org_details"),constant("roles.use_api"), constant("roles.modify_guidance"), constant("roles.modify_templates"), constant("roles.grant_permissions")])
  end

  def admin_update_permissions
    @user = User.includes(:roles).find(params[:id])
    authorize @user
    roles_ids = params[:role_ids].blank? ? [] : params[:role_ids].map(&:to_i)
    roles = Role.where( id: roles_ids)
    current_user.roles.each do |role|
      if @user.roles.include? role
        if ! roles.include? role
          @user.roles.delete(role)
          if role.name == constant("roles.use_api")
            @user.remove_token!
          end
        end
      else
        if roles.include? role
          @user.roles << role
          if role.name == constant("roles.use_api")
            @user.keep_or_generate_token!
          end
        end
      end
    end
    @user.save!
    respond_to do |format|
      format.html { redirect_to({controller: 'users', action: 'admin_index'}, {notice: I18n.t('helpers.success')})}
    end
  end

end
