class ResearchFiServiceController < ApplicationController
  include HTTParty
  require 'uri'

  def get_funding_decision
    # get funder_project_number from query param
    # and encode special unicode characters
    funder_project_number = URI.encode_www_form_component(params[:funder_project_number])
    # replace + with whitespace (to satisfy api constraint)
    funder_project_number = funder_project_number.gsub('+', ' ')
    # call api
    target_url = api_base_url + funding_decisions + '?funderProjectNumber=' + funder_project_number
    headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + self.get_access_token
    }
    response = HTTParty.get(target_url, headers: headers)
    Rails.logger.debug('ds-response: ')
    Rails.logger.debug(response)
    render json: { 
      research_fi_status_code: response.code.to_s,
      research_fi_status_message: response.message,
      research_fi_data: response.parsed_response 
    }
  end

  private

  def get_access_token
    headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
    body = {
      'grant_type': grant_type,
      'client_id': client_id,
      'client_secret': client_secret
    }
    response = HTTParty.post(research_fi_endpoint_for_access_tokens, headers: headers, body: body)
    response['access_token']
  end

  # Retrieve the config settings from the initialiser
  def api_base_url
    Rails.configuration.x.research_fi&.api_base_url || super
  end

  def active?
    Rails.configuration.x.research_fi&.active || super 
  end

  def funding_decisions
    Rails.configuration.x.research_fi&.funding_decisions || super
  end

  def client_id
    Rails.configuration.x.research_fi&.client_id || super
  end

  def client_secret 
    Rails.configuration.x.research_fi&.client_secret || super 
  end

  def grant_type
    Rails.configuration.x.research_fi&.grant_type || super 
  end

  def research_fi_endpoint_for_access_tokens
    Rails.configuration.x.research_fi&.research_fi_endpoint_for_access_tokens || super
  end
end
