class UsersController < ApplicationController
  
  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: I18n.t('admin.user_created') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to({:controller=> "projects", :action => "new"}, {:notice => I18n.t('helpers.project.create_success') }) }
				format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def admin_index
    authorize User
    @users = current_user.organisation.users.includes(:roles, :project_groups)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organisation_users }
    end
  end

  def admin_grant_permissions
    @user = User.includes(:roles).find(params[:id])
    authorize @user
    user_roles = current_user.roles
    @roles = user_roles & Role.where(name: [constant("user_role_types.change_org_details"),constant("user_role_types.use_api"), constant("user_role_types.modify_guidance"), constant("user_role_types.modify_templates"), constant("user_role_types.grant_permissions")])
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
          if role.name == constant("user_role_types.use_api")
            @user.remove_token!
          end
        end
      else
        if roles.include? role
          @user.roles << role
          if role.name == constant("user_role_types.use_api")
            @user.keep_or_generate_token!
          end
        end
      end
    end
    @user.save!
    respond_to do |format|
      format.html { redirect_to({controller: 'users', action: 'admin_index'}, {notice: I18n.t('helpers.success')})}
      format.json { head :no_content }
    end
  end

end
