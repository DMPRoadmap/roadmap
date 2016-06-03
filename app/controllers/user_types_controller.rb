class UserTypesController < ApplicationController
  # GET /user_types
  # GET /user_types.json
  def index
    @user_types = UserType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_types }
    end
  end

  # GET /user_types/1
  # GET /user_types/1.json
  def show
    @user_type = UserType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_type }
    end
  end

  # GET /user_types/new
  # GET /user_types/new.json
  def new
    @user_type = UserType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_type }
    end
  end

  # GET /user_types/1/edit
  def edit
    @user_type = UserType.find(params[:id])
  end

  # POST /user_types
  # POST /user_types.json
  def create
    @user_type = UserType.new(params[:user_type])

    respond_to do |format|
      if @user_type.save
        format.html { redirect_to @user_type, notice: 'User type was successfully created.' }
        format.json { render json: @user_type, status: :created, location: @user_type }
      else
        format.html { render action: "new" }
        format.json { render json: @user_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_types/1
  # PUT /user_types/1.json
  def update
    @user_type = UserType.find(params[:id])

    respond_to do |format|
      if @user_type.update_attributes(params[:user_type])
        format.html { redirect_to @user_type, notice: 'User type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_types/1
  # DELETE /user_types/1.json
  def destroy
    @user_type = UserType.find(params[:id])
    @user_type.destroy

    respond_to do |format|
      format.html { redirect_to user_types_url }
      format.json { head :no_content }
    end
  end
end
