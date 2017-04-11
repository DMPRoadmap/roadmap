class Users::OmniauthShibbolethRequestController < ApplicationController
  before_filter :authenticate_user!, only: :associate

  def redirect
  	if !current_user.nil? && !current_user.org.nil?
    	idp = params[:idp] || current_user.org.wayfless_entity
    else
    	idp = params[:idp]
    end
    
    # briley - April 10 2017 - Replaced the old path with the one currently defined in `rake routes`
    #query_params = {target: user_omniauth_callback_path(:shibboleth)}
    query_params = {target: user_shibboleth_omniauth_callback_path}
    
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
