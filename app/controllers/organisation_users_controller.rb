class OrganisationUsersController < ApplicationController
	
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
	
	

	
	
end