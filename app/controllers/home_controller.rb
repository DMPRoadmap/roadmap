class HomeController < ApplicationController
  def index
  	if user_signed_in?
  		name = current_user.name(false)
  		if name.nil? || name == "" then
  			redirect_to edit_user_registration_path
  		else
  			redirect_to projects_url
  		end
  	end
  end
  
  def about_us
  end

end
