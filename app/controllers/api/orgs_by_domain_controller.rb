# frozen_string_literal: true

module Api
  # Controller for API routes that return orgs by domain.
  class OrgsByDomainController < ApplicationController
    # GET /api/get-orgs-by-domain?domain=berkeley.edu
    def index
      domain_param = search_params[:domain]

      dummy_orgs = [
        {
          id: 'abc123def',
          org_name: 'University of California',
          domain: 'berkeley.edu'
        },
        {
          id: 'xyz789ghi',
          org_name: 'Massachusetts Institute of Technology',
          domain: 'mit.edu'
        },
        {
          id: 'mno456pqr',
          org_name: 'Stanford University',
          domain: 'stanford.edu'
        }
      ]

      # Filter orgs by domain if domain parameter is provided
      if domain_param.present?
        filtered_orgs = dummy_orgs.select { |org| org[:domain] == domain_param }

        # If no matches found, return the "OTHER" org
        if filtered_orgs.empty?
          other_org = [
            {
              ror_id: 'OTHER',
              org_name: 'OTHER',
              domain: 'OTHER'
            }
          ]
          render json: other_org
        else
          render json: filtered_orgs
        end
      else
        # If no domain parameter provided, return all dummy orgs
        render json: other_org
      end
    end

    private

    # Using Strong Parameters ensure only domain is permitted
    def search_params
      params.permit(:domain)
    end
  end
end
