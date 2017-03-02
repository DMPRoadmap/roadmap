class RolesController < ApplicationController
  respond_to :html
  after_action :verify_authorized

	def create
		@role = Role.new(params[:role])
    authorize @role
		@role.access_level = params[:role][:access_level].to_i
		if params[:role][:email].present?
			message = _('User added to project')
			if @role.save
				if @role.user.nil? then
					if User.find_by_email(params[:role][:email]).nil? then
						User.invite!(email: params[:role][:email])
						message = _('Invitation issued successfully.')
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
			flash[:notice] = _('Please enter an email address')
			redirect_to controller: 'plans', action: 'share', id: @role.plan.slug
		end
	end

	def update
  	@role = Role.find(params[:id])
    authorize @role
  	@role.access_level = params[:role][:access_level].to_i
		if @role.update_attributes(params[:role])
			flash[:notice] = _('Sharing details successfully updated.')
			UserMailer.permissions_change_notification(@role).deliver
			redirect_to controller: 'plans', action: 'share', id: @role.plan.slug
		else
			render action: "edit"
		end
	end

	def destroy
		@role = Role.find(params[:id])
    authorize @role
		user = @role.user
		plan = @role.plan
		@role.destroy

		flash[:notice] = _('Access removed')
		UserMailer.project_access_removed_notification(user, plan).deliver
	  redirect_to controller: 'plans', action: 'share', id: @role.plan.slug
	end
end