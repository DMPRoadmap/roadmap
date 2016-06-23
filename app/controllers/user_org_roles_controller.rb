class UserOrgRolesController < ApplicationController
  # GET /user_org_roles
  # GET /user_org_roles.json
  def index
    @user_org_roles = UserOrgRole.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_org_roles }
    end
  end

  # GET /user_org_roles/1
  # GET /user_org_roles/1.json
  def show
    @user_org_role = UserOrgRole.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_org_role }
    end
  end

  # GET /user_org_roles/new
  # GET /user_org_roles/new.json
  def new
    @user_org_role = UserOrgRole.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_org_role }
    end
  end

  # GET /user_org_roles/1/edit
  def edit
    @user_org_role = UserOrgRole.find(params[:id])
  end

  # POST /user_org_roles
  # POST /user_org_roles.json
  def create
    @user_org_role = UserOrgRole.new(params[:user_org_role])

    respond_to do |format|
      if @user_org_role.save
        format.html { redirect_to @user_org_role, notice: I18n.t('org_admin.user_org_created') }
        format.json { render json: @user_org_role, status: :created, location: @user_org_role }
      else
        format.html { render action: "new" }
        format.json { render json: @user_org_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_org_roles/1
  # PUT /user_org_roles/1.json
  def update
    @user_org_role = UserOrgRole.find(params[:id])

    respond_to do |format|
      if @user_org_role.update_attributes(params[:user_org_role])
        format.html { redirect_to @user_org_role, notice:  I18n.t('org_admin.user_org_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_org_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_org_roles/1
  # DELETE /user_org_roles/1.json
  def destroy
    @user_org_role = UserOrgRole.find(params[:id])
    @user_org_role.destroy

    respond_to do |format|
      format.html { redirect_to user_org_roles_url }
      format.json { head :no_content }
    end
  end
end
