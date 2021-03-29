# frozen_string_literal: true

class OauthsController < ApplicationController

  # GET /oauth/sign_in
  def new
    # The sign in location for OAuth authorizations

    redirect_to(root_url) if user_signed_in?

    @user = User.new
    render "oauths/new"
  end

end