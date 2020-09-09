# frozen_string_literal: true

# locals: plan

presenter = Api::V1::PlanPresenter.new(plan: plan)

json.title "Generic Dataset"
json.personal_data "unknown"
json.sensitive_data "unknown"

json.dataset_id do
  json.partial! "api/v1/identifiers/show", identifier: presenter.identifier
end

json.distribution [plan] do |distribution|
  json.title "PDF - #{distribution.title}"
  json.data_access "open"
  json.download_url Rails.application.routes.url_helpers.plan_export_url(distribution, format: :pdf)
  json.format do
    json.array! ["application/pdf"]
  end
end
