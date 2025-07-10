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
          pattern = "Other"
          other_org = Org.where("LOWER(orgs.name) = ?", pattern.downcase)
          result = other_org.map {|record|
            {
              id: record.id,
              org_name: record.name,
              domain: ""
            }
          }
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
