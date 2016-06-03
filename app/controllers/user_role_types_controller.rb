class UserRoleTypesController < ApplicationController
  # GET /user_role_types
  # GET /user_role_types.json
  def index
    @user_role_types = UserRoleType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_role_types }
    end
  end

  # GET /user_role_types/1
  # GET /user_role_types/1.json
  def show
    @user_role_type = UserRoleType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_role_type }
    end
  end

  # GET /user_role_types/new
  # GET /user_role_types/new.json
  def new
    @user_role_type = UserRoleType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_role_type }
    end
  end

  # GET /user_role_types/1/edit
  def edit
    @user_role_type = UserRoleType.find(params[:id])
  end

  # POST /user_role_types
  # POST /user_role_types.json
  def create
    @user_role_type = UserRoleType.new(params[:user_role_type])

    respond_to do |format|
      if @user_role_type.save
        format.html { redirect_to @user_role_type, notice: 'User role type was successfully created.' }
        format.json { render json: @user_role_type, status: :created, location: @user_role_type }
      else
        format.html { render action: "new" }
        format.json { render json: @user_role_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_role_types/1
  # PUT /user_role_types/1.json
  def update
    @user_role_type = UserRoleType.find(params[:id])

    respond_to do |format|
      if @user_role_type.update_attributes(params[:user_role_type])
        format.html { redirect_to @user_role_type, notice: 'User role type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_role_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_role_types/1
  # DELETE /user_role_types/1.json
  def destroy
    @user_role_type = UserRoleType.find(params[:id])
    @user_role_type.destroy

    respond_to do |format|
      format.html { redirect_to user_role_types_url }
      format.json { head :no_content }
    end
  end
end
