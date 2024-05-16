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
      # Ensure that the api_target is a full callable URL
      base_url = Rails.env.development? ? 'http://localhost:3000' : "#{Rails.configuration.x.dmproadmap.server_host}"
      base_url += '/' unless base_url.strip.end_with?('/')
      api_target = org.api_target.start_with?('/') ? org.api_target[1..(org.api_target.strip.length - 1)] : org.api_target
      url = api_target.start_with?('http') ? api_target : "#{base_url.strip}#{api_target.strip}"

      json.funder_api url
      json.funder_api_guidance org.api_guidance
      json.funder_api_query_fields org.api_query_fields.is_a?(String) ? JSON.parse(org.api_query_fields) : org.api_query_fields
    end
  else
    json.affiliation_id do
      json.type 'ror'
      ror_id = org.ror_id.gsub(%r{https?://}, '').gsub('ror.org', '')
      ror_id = ror_id.start_with?('/') ? ror_id : "/#{ror_id}"
      json.identifier "https://ror.org#{ror_id}"
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
