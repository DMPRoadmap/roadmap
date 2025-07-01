# frozen_string_literal: true

module Api
  # Controller for API routes that return orgs by domain.
  class OrgsByDomainController < ApplicationController
    def index
      dummy_orgs = [
        {
          ror_id: 'abc123def',
          org_name: 'University of California',
          domain: 'berkeley.edu'
        },
        {
          ror_id: 'xyz789ghi',
          org_name: 'Massachusetts Institute of Technology',
          domain: 'mit.edu'
        },
        {
          ror_id: 'mno456pqr',
          org_name: 'Stanford University',
          domain: 'stanford.edu'
        }
      ]

      render json: dummy_orgs
    end
  end
end
