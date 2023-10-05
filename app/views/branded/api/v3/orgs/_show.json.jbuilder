# frozen_string_literal: true

# locals: org, use_funder_context

use_funder_context = local_assigns.fetch(:use_funder_context, false)

json.name org.name

if org.is_a?(RegistryOrg)
  json.acronym org.acronyms.first if org.acronyms.any?

  if use_funder_context
    json.funder_id do
      json.type 'fundref'
      json.identifier "https://api.crossref.org/funders/#{org.fundref_id}"
    end

    if org.api_target.present?
      base_url = "#{Rails.configuration.x.dmproadmap.server_host}"
      base_url = "https://#{base_url}" unless base_url.start_with?('http')
      base_url = "#{base_url}/" unless base_url.end_with?('/')
      url = org.api_target if org.api_target.start_with?('http')
      url = "#{base_url}#{org.api_target.start_with?('/') ? org.api_target : "/#{org.api_target}"}" if url.nil?

      json.funder_api url
      json.funder_api_guidance org.api_guidance
      json.funder_api_query_fields org.api_query_fields.is_a?(String) ? JSON.parse(org.api_query_fields) : org.api_query_fields
    end
  else
    json.affiliation_id do
      json.type 'ror'
      json.identifier "https://ror.org/#{org.ror_id}"
    end
  end

else
  if org.identifiers.any?
    if use_funder_context
      json.funder_id do
        id = Api::V1::OrgPresenter.affiliation_id(identifiers: org.identifiers)
        json.partial! 'api/v3/identifiers/show', identifier: id
      end
    else
      json.affiliation_id do
        id = Api::V1::OrgPresenter.affiliation_id(identifiers: org.identifiers)
        json.partial! 'api/v3/identifiers/show', identifier: id
      end
    end
  end
end
