class Arpha::ConnectionsController < Arpha::BaseController

  def create
    response = arpha_api_post(action: "get_api_key",
                              username: params[:username],
                              password: params[:password])

    api_key = parse_arpha_xml(xml: response.body, node: "returnResult")
    if api_key.present?
      current_user.update!(arpha_api_key: api_key, arpha_username: params[:username])
      redirect_to :back, notice: _("Successfully connected your Arpha account")
    else
      flash[:alert] = _("There was an error trying to connect your Arpha account: #{response.body}")
      redirect_to :back
    end
  end

end
