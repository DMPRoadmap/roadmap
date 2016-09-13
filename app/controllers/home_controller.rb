class HomeController < ApplicationController
  after_action :verify_authorized

  def index
    authorize User
  	if user_signed_in?
  		name = current_user.name(false)
  		if name.blank?
  			redirect_to edit_user_registration_path
  		else
  			redirect_to projects_url
  		end
  	end
  end

end
