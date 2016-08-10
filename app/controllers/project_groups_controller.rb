class ProjectGroupsController < ApplicationController

	def create
		@project_group = ProjectGroup.new(params[:project_group])
		access_level = params[:project_group][:access_level].to_i
		if access_level >= 3 then
  			@project_group.project_administrator = true
  		end
  		if access_level >= 2 then
  			@project_group.project_editor = true
  		end
  		if (user_signed_in?) && @project_group.project.administerable_by(current_user.id) then
			respond_to do |format|
				if params[:project_group][:email].present? && params[:project_group][:email].length > 0 then
					message = I18n.t('helpers.project.user_added')
					if @project_group.save
						if @project_group.user.nil? then
							if User.find_by_email(params[:project_group][:email]).nil? then
								User.invite!(:email => params[:project_group][:email])
								message = I18n.t('helpers.project.invitation_success')
								@project_group.user = User.find_by_email(params[:project_group][:email])
								@project_group.save
							else
								@project_group.user = User.find_by_email(params[:project_group][:email])
								@project_group.save
								UserMailer.sharing_notification(@project_group).deliver
							end
						else
							UserMailer.sharing_notification(@project_group).deliver
						end
						flash[:notice] = message
						format.html { redirect_to :controller => 'projects', :action => 'share', :id => @project_group.project.slug }
						format.json { render json: @project_group, status: :created, location: @project_group }
					else
						format.html { render action: "new" }
						format.json { render json: @project_group.errors, status: :unprocessable_entity }
					end
				else
					flash[:notice] = I18n.t('helpers.project.enter_email')
					format.html { redirect_to :controller => 'projects', :action => 'share', :id => @project_group.project.slug }
					format.json { render json: @project_group, status: :created, location: @project_group }
				end
			end
		else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end

	end

	def update
    	@project_group = ProjectGroup.find(params[:id])
    	access_level = params[:project_group][:access_level].to_i
		if access_level >= 3 then
  			@project_group.project_administrator = true
  		else
  			@project_group.project_administrator = false
  		end
  		if access_level >= 2 then
  			@project_group.project_editor = true
  		else
  			@project_group.project_editor = false
  		end
    	if (user_signed_in?) && @project_group.project.administerable_by(current_user.id) then
			respond_to do |format|
				if @project_group.update_attributes(params[:project_group])
					flash[:notice] = I18n.t('helpers.project.sharing_updated')
					UserMailer.permissions_change_notification(@project_group).deliver
					format.html { redirect_to :controller => 'projects', :action => 'share', :id => @project_group.project.slug }
					format.json { head :no_content }
				else
					format.html { render action: "edit" }
					format.json { render json: @project_group.errors, status: :unprocessable_entity }
				 end
			end
    	else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  	end

	def destroy
		@project_group = ProjectGroup.find(params[:id])
		if (user_signed_in?) && @project_group.project.administerable_by(current_user.id) then
			user = @project_group.user
			project = @project_group.project
			@project_group.destroy
			respond_to do |format|
				flash[:notice] = I18n.t('helpers.project.access_removed')
				UserMailer.project_access_removed_notification(user, project).deliver
				format.html { redirect_to :controller => 'projects', :action => 'share', :id => @project_group.project.slug }
				format.json { head :no_content }
			end
		else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
	end
end