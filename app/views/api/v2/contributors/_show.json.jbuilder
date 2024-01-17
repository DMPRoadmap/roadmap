# frozen_string_literal: true

# locals: contributor, is_contact

is_contact ||= false

json.name contributor.is_a?(User) ? contributor.name(false) : contributor.name
json.mbox contributor.email

if !is_contact && contributor.selected_roles.any?
  roles = contributor.selected_roles.map do |role|
    Api::V1::ContributorPresenter.role_as_uri(role: role)
  end
  json.role roles if roles.any?
end

if contributor.org.present? && ['No funder', 'Non Partner Institution'].exclude?(contributor.org.name)
  json.dmproadmap_affiliation do
    json.partial! 'api/v2/orgs/show', org: contributor.org
  end
end

orcid = contributor.identifier_for_scheme(scheme: 'orcid')
if orcid.present?
  id = Api::V1::ContributorPresenter.contributor_id(
    identifiers: contributor.identifiers
  )
  if is_contact
    json.contact_id do
      json.partial! 'api/v2/identifiers/show', identifier: id
    end
  else
    json.contributor_id do
      json.partial! 'api/v2/identifiers/show', identifier: id
    end
  end
elsif is_contact
  json.contact_id do
    json.type 'other'
    json.identifier contributor.email
  end
end
