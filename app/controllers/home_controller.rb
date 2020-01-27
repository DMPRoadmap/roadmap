# frozen_string_literal: true

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
      # TODO: Investigate if this is even relevant anymore.
      # The name var will never be blank here because the logic in
      # User says to return the email if the firstname and surname are empty
      # regardless of the flag passed in
      if name.blank?
        redirect_to edit_user_registration_path
      else
        redirect_to plans_url
      end
    elsif session["devise.shibboleth_data"].present?
      # NOTE: Update this to handle ORCiD as well when we enable it as a login method
      redirect_to new_user_registration_url
    end
  end

end
