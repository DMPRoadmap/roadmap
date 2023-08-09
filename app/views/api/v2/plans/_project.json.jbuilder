# frozen_string_literal: true

# locals: plan

json.title plan.title
json.description description_for_json(str: plan.description)

start_date = plan.start_date || Time.zone.now
json.start start_date.to_formatted_s(:iso8601)

end_date = plan.end_date || 2.years.from_now
json.end end_date&.to_formatted_s(:iso8601)

if plan.funder.present? || plan.grant_id.present?
  json.funding [plan] do
    json.partial! 'api/v2/plans/funding', plan: plan
  end
end
