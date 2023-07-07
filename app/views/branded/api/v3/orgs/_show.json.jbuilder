# frozen_string_literal: true

# locals: org, use_funder_context

use_funder_context = local_assigns.fetch(:use_funder_context, false)

json.name org.name

if org.is_a?(RegistryOrg)
  if use_funder_context
    json.funder_id do
      json.type 'fundref'
      json.identifier "https://api.crossref.org/funders/#{org.fundref_id}"
    end

    json.acronyms org.acronyms if org.acronyms.present?
    json.aliases org.aliases if org.aliases.present?
    json.types org.types if org.types.present?
    json.country org.country if org.country.present?

    if org.api_target.present?
      json.funder_api org.api_target
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
