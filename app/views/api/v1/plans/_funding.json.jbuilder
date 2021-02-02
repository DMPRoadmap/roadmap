# frozen_string_literal: true

# locals: plan

json.name plan.funder&.name

if plan.funder.present?
  id = Api::V1::OrgPresenter.affiliation_id(identifiers: plan.funder.identifiers)

  if id.present?
    json.funder_id do
      json.partial! "api/v1/identifiers/show", identifier: id
    end
  end
end

if plan.grant_id.present? && plan.grant.present?
  json.grant_id do
    json.partial! "api/v1/identifiers/show", identifier: plan.grant
  end
end
json.funding_status plan.grant.present? ? "granted" : "planned"

# DMPTool extensions to the RDA common metadata standard
if plan.identifier.present?
  json.dmproadmap_funding_opportunity_identifier do
    json.partial! "api/v1/identifiers/show", identifier: Identifier.new(identifiable: plan,
                                                                        value: plan.identifier)
  end
end
json.dmproadmap_funded_affiliations [plan.org] do |funded_org|
  json.partial! "api/v1/orgs/show", org: funded_org
end
