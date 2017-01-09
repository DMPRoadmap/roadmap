class RolesController < ApplicationController
  after_action :verify_authorized

	def create
		@role = Role.new(params[:role])
    authorize @role
		access_level = params[:role][:access_level].to_i
		if access_level >= 3 then
		  @role.administrator = true
		end
		if access_level >= 2 then
			@role.editor = true
		end
		if (user_signed_in?) && @role.plan.administerable_by(current_user.id) then
    	respond_to do |format|
    		if params[:role][:email].present? && params[:role][:email].length > 0 then
    			message = I18n.t('helpers.project.user_added')
    			if @role.save
    				if @role.user.nil? then
    					if User.find_by_email(params[:role][:email]).nil? then
    						User.invite!(email: params[:role][:email])
    						message = I18n.t('helpers.project.invitation_success')
    						@role.user = User.find_by_email(params[:role][:email])
    						@role.save
    					else
    						@role.user = User.find_by_email(params[:role][:email])
    						@role.save
    						UserMailer.sharing_notification(@role).deliver
    					end
    				else
    					UserMailer.sharing_notification(@role).deliver
    				end
    				flash[:notice] = message
    				format.html { redirect_to controller: 'plans', action: 'share', id: @role.plan.slug }
    			else
    				format.html { render action: "new" }
    			end
    		else
    			flash[:notice] = I18n.t('helpers.project.enter_email')
    			format.html { redirect_to controller: 'plans', action: 'share', id: @role.plan.slug }
    		end
    	end
		else
			render(file: File.join(Rails.root, 'public/403.html'), status: 403, layout: false)
		end
	end

	def update
    	@role = Role.find(params[:id])
      authorize @role
    	access_level = params[:role][:access_level].to_i
		if access_level >= 3 then
  			@role.administrator = true
  		else
  			@role.administrator = false
  		end
  		if access_level >= 2 then
  			@role.editor = true
  		else
  			@role.administrator = false
  		end
    	if (user_signed_in?) && @role.plan.administerable_by(current_user.id) then
			respond_to do |format|
				if @role.update_attributes(params[:role])
					flash[:notice] = I18n.t('helpers.project.sharing_updated')
					UserMailer.permissions_change_notification(@role).deliver
					format.html { redirect_to controller: 'plans', action: 'share', id: @role.plan.slug }
				else
					format.html { render action: "edit" }
				 end
			end
    	else
			render(:file => File.join(Rails.root, 'public/403.html'), status: 403, layout: false)
		end
  	end

	def destroy
		@role = Role.find(params[:id])
    authorize @role
		if (user_signed_in?) && @role.plan.administerable_by(current_user.id) then
			user = @role.user
			plan = @role.plan
			@role.destroy
			respond_to do |format|
				flash[:notice] = I18n.t('helpers.project.access_removed')
				UserMailer.project_access_removed_notification(user, plan).deliver
				format.html { redirect_to controller: 'plans', action: 'share', id: @role.plan.slug }
			end
		else
			render(file: File.join(Rails.root, 'public/403.html'), status: 403, layout: false)
		end
	end
end