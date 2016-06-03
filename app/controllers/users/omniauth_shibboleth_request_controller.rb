class Users::OmniauthShibbolethRequestController < ApplicationController
  before_filter :authenticate_user!, :only => :associate

  def redirect
  	if !current_user.nil? && !current_user.organisation.nil?
    	idp = params[:idp] || current_user.organisation.wayfless_entity
    else
    	idp = params[:idp]
    end
    query_params = {target: user_omniauth_callback_path(:shibboleth)}
    unless idp.blank?
      query_params[:entityID] = idp
    end
    redirect_to "#{Rails.application.config.shibboleth_login}?#{query_params.to_query}", status: 302
  end

  def associate
    # This action is protected - can only be reached if user is already logged in.
    # See before_filter
    redirect_to user_omniauth_callback_path(:shibboleth)
  end
end
