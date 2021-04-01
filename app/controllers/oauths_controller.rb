# frozen_string_literal: true

class OauthsController < Doorkeeper::ApplicationController

  # GET /oauth/sign_in
  def new
    # The sign in location for OAuth authorizations
    redirect_to(root_url) if user_signed_in?

    @user = User.new
    host = URI(session[:redirect_uri]).host
    render "Unauthorized" unless host.present?

    api_client = ApiClient.find_by("redirect_uri LIKE ?", "%#{host}%")
    render "Unauthorized" unless api_client.present?

    render "oauths/new", layout: "doorkeeper/application", locals: { client: api_client }
  end

end