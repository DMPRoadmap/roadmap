# frozen_string_literal: true

module Api
  # Controller for API routes that return orgs by domain.
  class OrgDomainController < ApplicationController
    # GET /api/get-orgs-by-domain?domain=berkeley.edu
    def index
      email_param = search_params[:email]
      email_domain = email_param.split('@').last if email_param.present? && email_param.include?('@')

      # Filter orgs by domain if domain parameter is provided
      if email_param.present?
        # filtered_orgs = dummy_orgs.select { |org| org[:domain] == email_domain }
        org_results = OrgDomain.search_with_org_info(email_domain)

        result = org_results.map { |record|
          {
            id: record.id,
            org_name: record.org_name,
            domain: record.domain
          }
        }

        if result.empty?
        #---------Call OrionService to search by domain
        ror_id = ::ExternalApis::OrionService.search_by_domain(email_domain)
        full_org_json = ::ExternalApis::OrionService.search_by_ror_id(ror_id[0])
        # Extract the value for "Digital Curation Centre"
        result = full_org_json.map do |org|
          next unless org.is_a?(Hash)
        
          # Find title from names
          title = org["names"]&.find { |n| n["types"]&.include?("label") }&.dig("value")
        
          # Use org id as-is
          id = org["id"].split("/").last
        
          # Get first domain, if any
          domain = org["domains"]&.first
        
          # Return structured hash
          {
            id: id,
            org_name: title,
            domain: domain || ""
          }
        end.compact   
        #---------Orion service code end
        end
          render json: result
      else
          render json: [], status: :ok
      end
    end

    private

    # Using Strong Parameters ensure only domain is permitted
    def search_params
      params.permit(:email, :format)
    end
  end
end
