# frozen_string_literal

class Oauth2Controller < ApplicationController

  include OAuthable


  SCOPE_FOR_PROVIDER = {
    'zenodo' => "deposit:write deposit:actions"
  }

  # Base URL for this app. Will not use SSL if host is localhost
  REDIRECT_URI = begin
    scheme = ENV['HOST'].to_s.starts_with?('localhost') ? 'http' : "https"
    "#{scheme}://#{ENV['HOST']}/oauth2/callback/%{provider}"
  end

  def authorize
    session[:"#{params[:provider]}_plan_id"] = params[:plan_id]
    client = client_for_oauth2_provider(params[:provider])
    redirect_to client.auth_code.authorize_url({
      redirect_uri: REDIRECT_URI % params,
      scope: SCOPE_FOR_PROVIDER[params[:provider]],
      provider: params[:provider]
    })
  end

  def callback
    client = client_for_oauth2_provider(params[:provider])
    @token = client.auth_code.get_token(params[:code],
                                        redirect_uri: REDIRECT_URI % params)
    current_user.update!(zenodo_access_token: @token.token)
    @plan = current_user.plans.find_by(id: session[:"#{params[:provider]}_plan_id"])
    session[:"#{params[:provider]}_plan_id"] = nil
    if @plan
      redirect_to share_plan_url(@plan),
                  notice: "Successfully connected #{params[:provider]}"
    else
      redirect_to plans_url(custom: params[:custom]),
                  notice: "Successfully connected #{params[:provider]}"
    end

  end

end
