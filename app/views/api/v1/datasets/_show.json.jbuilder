# frozen_string_literal: true

# locals: plan

presenter = Api::V1::PlanPresenter.new(plan: plan)

json.title "Generic Dataset"
json.personal_data "unknown"
json.sensitive_data "unknown"

json.dataset_id do
  json.partial! "api/v1/identifiers/show", identifier: presenter.identifier
end
