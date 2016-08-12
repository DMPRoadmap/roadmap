# app/controllers/sessions_controller.rb
class SessionsController < Devise::SessionsController

	def create
		existing_user = User.find_by_email(params[:user][:email])
        
      	if !existing_user.nil? && (existing_user.password == "" || existing_user.password.nil?) && existing_user.confirmed_at.nil? then
  			redirect_to :controller => :existing_users, :action => :index, :email => params[:user][:email]
		else
			#after authentication verify if session[:shibboleth] exists
            if !params[:shibboleth_data].nil? then
                existing_user.update_attributes(:shibboleth_id => session[:shibboleth_data][:uid])
            end
            super
            
		end
	end
	
	def destroy
        current_user.plan_sections.each do |lock|
            lock.delete
            
        end
        super
    end

end