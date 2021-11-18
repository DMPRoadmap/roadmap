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
