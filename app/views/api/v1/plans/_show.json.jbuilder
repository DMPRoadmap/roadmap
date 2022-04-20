# frozen_string_literal: true

# locals: plan

json.schema 'https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard/tree/master/examples/JSON/JSON-schema/1.0'

presenter = Api::V1::PlanPresenter.new(plan: plan)

# Note the symbol of the dmproadmap json object
# nested in extensions which is the container for the json template object, etc.

# A JSON representation of a Data Management Plan in the
# RDA Common Standard format
json.title plan.title
json.description plan.description
json.language Api::V1::LanguagePresenter.three_char_code(
  lang: LocaleService.default_locale
)
json.created plan.created_at.to_formatted_s(:iso8601)
json.modified plan.updated_at.to_formatted_s(:iso8601)

json.ethical_issues_exist Api::V1::ConversionService.boolean_to_yes_no_unknown(plan.ethical_issues)
json.ethical_issues_description plan.ethical_issues_description
json.ethical_issues_report plan.ethical_issues_report

id = presenter.identifier
if id.present?
  json.dmp_id do
    json.partial! 'api/v1/identifiers/show', identifier: id
  end
end

if presenter.data_contact.present?
  json.contact do
    json.partial! 'api/v1/contributors/show', contributor: presenter.data_contact,
                                              is_contact: true
  end
end

unless @minimal
  if presenter.contributors.any?
    json.contributor presenter.contributors do |contributor|
      json.partial! 'api/v1/contributors/show', contributor: contributor,
                                                is_contact: false
    end
  end

  if presenter.costs.any?
    json.cost presenter.costs do |cost|
      json.partial! 'api/v1/plans/cost', cost: cost
    end
  end

  json.project [plan] do |pln|
    json.partial! 'api/v1/plans/project', plan: pln
  end

  outputs = plan.research_outputs.any? ? plan.research_outputs : [plan]

  json.dataset outputs do |output|
    json.partial! "api/v1/datasets/show", output: output
  end

  json.extension [plan.template] do |template|
    json.set! :dmproadmap do
      json.template do
        json.id template.id
        json.title template.title
      end
    end
  end
end
