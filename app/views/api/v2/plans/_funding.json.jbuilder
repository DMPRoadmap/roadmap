# frozen_string_literal: true

# locals: plan

json.name plan.funder&.name

if plan.funder.present?
  id = Api::V2::OrgPresenter.affiliation_id(identifiers: plan.funder.identifiers)

  if id.present?
    json.funder_id do
      json.partial! 'api/v2/identifiers/show', identifier: id
    end
  end
end

if plan.grant_id.present? && plan.grant.present?
  json.grant_id do
    json.partial! 'api/v2/identifiers/show', identifier: plan.grant
  end
end

json.funding_status Api::V2::FundingPresenter.status(plan: plan)

# DMPTool extensions to the RDA common metadata standard
# ------------------------------------------------------

# We collect a user entered ID on the form, so this is a way to convey it to other systems
# The ID would typically be something relevant to the funder or research organization
if plan.identifier.present?
  json.dmproadmap_funding_opportunity_id do
    json.partial! 'api/v2/identifiers/show', identifier: Identifier.new(identifiable: plan,
                                                                        value: plan.identifier)
  end
end

# Since the Plan owner (aka contact) and contributor orgs could be different than the
# one associated with the Plan, we add it here.
json.dmproadmap_funded_affiliations [plan.org] do |funded_org|
  json.partial! 'api/v2/orgs/show', org: funded_org
end
