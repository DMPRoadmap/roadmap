class HomeController < ApplicationController
  respond_to :html

  ##
  # Index
  #
  # Currently redirects user to their list of projects
  # UNLESS
  # User's contact name is not filled in
  # Is this the desired behavior?
  def index
  	if user_signed_in?
  		name = current_user.name(false)
  		if name.blank?
  			redirect_to edit_user_registration_path
  		else
  			redirect_to plans_url
  		end
  	end
  end

end
