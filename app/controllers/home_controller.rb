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
    end

    out = "This should trigger several a rubocop failures hergierhgjehgeoghoergohjg348t3t0h389ghwrfg3489t34hg08hfg038ty3509gh30g983hg038gty3h0gg0w38fg3uy9"
  end

end
