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
        if user_signed_in? && current_user.is_org_admin? then
            respond_to do |format|
                format.html # index.html.erb
                format.json { render json: @organisation_users }
            end
        else
            render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
        end
  end

    def admin_api_update
        if user_signed_in? && current_user.is_org_admin? then
          #iterate through all org users
          user_ids = params[:api_user_ids].blank? ? [] : params[:api_user_ids].map(&:to_i)
          admin_user_ids = params[:org_admin_ids].blank? ? [] : params[:org_admin_ids].map(&:to_i)
          current_user.organisation.users.each do |user|
            # if user_id in passed params
            if user_ids.include? user.id
              # run generate_or_keep
              user.keep_or_generate_token!
            # if not in passed params
            else
              # remove the token
              user.remove_token!
            end
            # ORG_ADMINS
            if admin_user_ids.include?( user.id) && !user.is_org_admin?
              # add admin privleges
              # MAGIC_STRING
              user.roles << Role.find_by(name: constant("user_role_types.organisational_admin"))
            # if user_id not in passed, but user is an admin
            elsif !admin_user_ids.include?(user.id) && user.is_org_admin?
              # strip admin privleges
              user.roles.delete(Role.find_by(name: constant("user_role_types.organisational_admin")))
            end
          end
            #redirect_to admin_index
        else
            render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
        end
    end

end
