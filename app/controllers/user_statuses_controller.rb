class UserStatusesController < ApplicationController
  # GET /user_statuses
  # GET /user_statuses.json
  def index
    @user_statuses = UserStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_statuses }
    end
  end

  # GET /user_statuses/1
  # GET /user_statuses/1.json
  def show
    @user_status = UserStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_status }
    end
  end

  # GET /user_statuses/new
  # GET /user_statuses/new.json
  def new
    @user_status = UserStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_status }
    end
  end

  # GET /user_statuses/1/edit
  def edit
    @user_status = UserStatus.find(params[:id])
  end

  # POST /user_statuses
  # POST /user_statuses.json
  def create
    @user_status = UserStatus.new(params[:user_status])

    respond_to do |format|
      if @user_status.save
        format.html { redirect_to @user_status, notice: I18n.t('admin.user_status_created') }
        format.json { render json: @user_status, status: :created, location: @user_status }
      else
        format.html { render action: "new" }
        format.json { render json: @user_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_statuses/1
  # PUT /user_statuses/1.json
  def update
    @user_status = UserStatus.find(params[:id])

    respond_to do |format|
      if @user_status.update_attributes(params[:user_status])
        format.html { redirect_to @user_status, notice: I18n.t('admin.user_status_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_statuses/1
  # DELETE /user_statuses/1.json
  def destroy
    @user_status = UserStatus.find(params[:id])
    @user_status.destroy

    respond_to do |format|
      format.html { redirect_to user_statuses_url }
      format.json { head :no_content }
    end
  end
end
