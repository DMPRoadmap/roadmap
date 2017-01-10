class RolesController < ApplicationController
  respond_to :html
  after_action :verify_authorized

	def create
		@role = Role.new(params[:role])
    authorize @role
		@role.access_level = params[:role][:access_level].to_i
		if params[:role][:email].present?
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
				redirect_to controller: 'plans', action: 'share', id: @role.plan.slug
			else
				render action: "new"
			end
		else
			flash[:notice] = I18n.t('helpers.project.enter_email')
			redirect_to controller: 'plans', action: 'share', id: @role.plan.slug
		end
	end

	def update
    	@role = Role.find(params[:id])
      authorize @role
    	@role.access_level = params[:role][:access_level].to_i
			if @role.update_attributes(params[:role])
				flash[:notice] = I18n.t('helpers.project.sharing_updated')
				UserMailer.permissions_change_notification(@role).deliver
				redirect_to controller: 'plans', action: 'share', id: @role.plan.slug
			else
				render action: "edit"
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