# frozen_string_literal: true

# locals: plan

json.title plan.title
json.description plan.description
json.start plan.start_date&.utc&.to_s
json.end plan.end_date&.utc&.to_s

if plan.funder.present? || plan.grant_id.present?
  json.funding [plan] do
    json.partial! "api/v1/plans/funding", plan: plan
  end
end
