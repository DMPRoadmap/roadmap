# frozen_string_literal: true

# locals: plan

json.ignore_nil!

extensions = [{ name: "dmproadmap", uri: "https://github.com/DMPRoadmap/api-json-schema" }]
json.extensions extensions do |extension|
  json.uri extension[:uri]
  json.name extension[:name]
end

presenter = Api::V1::PlanPresenter.new(plan: plan)
# A JSON representation of a Data Management Plan in the
# RDA Common Standard format
json.title plan.title
json.description plan.description
json.language Api::V1::LanguagePresenter.three_char_code(
  lang: LocaleService.default_locale
)
json.created plan.created_at.to_formatted_s(:iso8601)
json.modified plan.updated_at.to_formatted_s(:iso8601)

# TODO: Update this to pull from the appropriate question once the work is complete
json.ethical_issues_exist Api::V1::ConversionService.boolean_to_yes_no_unknown(plan.ethical_issues)
json.ethical_issues_description plan.ethical_issues_description
json.ethical_issues_report plan.ethical_issues_report

id = presenter.identifier
if id.present?
  json.dmp_id do
    json.partial! "api/v1/identifiers/show", identifier: id
  end
end

if presenter.data_contact.present?
  json.contact do
    json.partial! "api/v1/contributors/show", contributor: presenter.data_contact,
                                              is_contact: true
  end
end

unless @minimal
  if presenter.contributors.any?
    json.contributor presenter.contributors do |contributor|
      json.partial! "api/v1/contributors/show", contributor: contributor,
                                                is_contact: false
    end
  end

  if presenter.costs.any?
    json.cost presenter.costs do |cost|
      json.partial! "api/v1/plans/cost", cost: cost
    end
  end

  json.project [plan] do |pln|
    json.partial! "api/v1/plans/project", plan: pln
  end

  outputs = plan.research_outputs.any? ? plan.research_outputs : [plan]

  json.dataset outputs do |output|
    json.partial! "api/v1/datasets/show", output: output
  end

  # DMPRoadmap extensions to the RDA common metadata standard
  json.dmproadmap_template do
    json.id plan.template.id
    json.title plan.template.title
  end

  # Any related identifiers known by the DMPTool
  json.dmproadmap_related_identifiers plan.related_identifiers do |related|
    next unless related.value.present? && related.relation_type.present?

    json.descriptor related.relation_type
    json.type related.identifier_type
    json.identifier related.value
  end

  json.dmproadmap_privacy presenter.visibility

  # DMPRoadmap specific links to perform special actions like downloading the PDF
  json.dmproadmap_links presenter.links

  # DMPHub extension to send all callback addresses for interested subscribers for changes to the DMP
  json.dmphub_subscribers presenter.subscriptions
end
