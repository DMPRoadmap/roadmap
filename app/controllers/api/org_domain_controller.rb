# frozen_string_literal: true

module Api
  # Controller for API routes that return orgs by domain.
  class OrgDomainController < ApplicationController

    # PUTS /api/orgs-by-domain with parameter email.
    #TBD: Change these Rubocop Cops
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def index
      email_param = search_params[:email]
      email_domain = email_param.split('@').last if email_param.present? && email_param.include?('@')
      render json: [], status: :ok if email_domain.blank?

      # Filter orgs by domain if domain parameter is provided
      org_results = OrgDomain.search_with_org_info(email_domain)
      result = org_results.map { |record|
        {
          id: record.id,
          org_name: record.org_name,
          domain: record.domain,
        }
      }

      unless result.empty?
        puts "result: #{result}"
        render json: result, status: :ok
        return
      end
    
      #---------Orion service code start
      begin
        full_org_json = ::ExternalApis::OrionService.search_by_domain(email_domain)
        puts "full_org_json: #{full_org_json}"

        unless full_org_json&.key?('orgs')
          puts 'Invalid response or no orgs key found'
          other_org = Org.find_other_org
          result = [{
            id: other_org.id,
            org_name: other_org.name,
            domain: ''
          }]
          render json: result, status: :ok
          return
        end

        # Extract the value
        result = full_org_json['orgs'].map do |org|
          title = org['names'].find { |n| n['types'].include?('ror_display') }
          {
            id: org['id'].split('/').last,
            org_name: title ? title['value'] : 'Name not found',
            domain: '',
          }
        rescue => e
          puts "Failed request: #{e.message}"
          result = []
        end

        # Fallback if still no results
        if result.blank?
          other_org = Org.find_other_org
          result = [{
            id: other_org.id,
            org_name: other_org.name,
            domain: ''
          }]
        end
      end
      render json: result, status: :ok
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    private

    # Using Strong Parameters ensure only domain is permitted
    def search_params
      params.permit(:email, :format, :org_domain)
    end
  end
end
