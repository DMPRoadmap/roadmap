# frozen_string_literal: true

class HomeController < ApplicationController

  include Dmptool::Controller::Home

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
      # The RolesController defaults the firstname and surname (both required fields)
      # to 'FirstName' and 'Surname' when a plan is shared with an unknown user
      if name == "First Name Surname"
        redirect_to edit_user_registration_path
      else
        redirect_to plans_url
      end

    # -------------------------------------------------
    # Start DMPTool customization
    # -------------------------------------------------
    else
      render_home_page
    # -------------------------------------------------
    # End DMPTool customization
    # -------------------------------------------------
    end
  end

end
