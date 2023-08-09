# frozen_string_literal: true

# locals: plan

plan = plan.first if plan.is_a?(Array)
@client = client if @client.blank?

json.ignore_nil!

presenter = Api::V2::PlanPresenter.new(plan: plan, client: @client)
# A JSON representation of a Data Management Plan in the
# RDA Common Standard format
json.title plan.title
# Strip out empty paragraphs from the description

json.description description_for_json(str: plan.description)
json.language Api::V1::LanguagePresenter.three_char_code(
  lang: LocaleService.default_locale
)
json.created plan.created_at.to_formatted_s(:iso8601)
json.modified plan.updated_at.to_formatted_s(:iso8601)

json.ethical_issues_exist Api::V2::ConversionService.boolean_to_yes_no_unknown(plan.ethical_issues)
json.ethical_issues_description plan.ethical_issues_description
json.ethical_issues_report plan.ethical_issues_report

json.dmp_id do
  if plan.dmp_id.present?
    json.type 'doi'
    json.identifier plan.dmp_id
  else
    json.type 'url'
    json.identifier Rails.application.routes.url_helpers.api_v2_plan_url(plan)
  end
end

if presenter.data_contact.present?
  json.contact do
    json.partial! 'api/v2/contributors/show', contributor: presenter.data_contact,
                                              is_contact: true
  end
end

unless @minimal
  if presenter.contributors.any?
    json.contributor presenter.contributors do |contributor|
      json.partial! 'api/v2/contributors/show', contributor: contributor,
                                                is_contact: false
    end
  end

  if presenter.costs.any?
    json.cost presenter.costs do |cost|
      json.partial! 'api/v2/plans/cost', cost: cost
    end
  end

  json.project [plan] do |pln|
    json.partial! 'api/v2/plans/project', plan: pln
  end

  outputs = plan.research_outputs.any? ? plan.research_outputs : [plan]

  json.dataset outputs do |output|
    json.partial! 'api/v2/datasets/show', output: output
  end

  # DMPRoadmap extensions to the RDA common metadata standard
  json.dmproadmap_template do
    json.id plan.template.family_id.to_s
    json.title plan.template.title
  end

  json.dmproadmap_featured plan.featured? ? '1' : '0'

  # If the plan was created via the API and the external system provided an identifier,
  # return that value
  external_id = presenter.external_system_identifier
  json.dmproadmap_external_system_identifier external_id.is_a?(Identifier) ? external_id.value : external_id

  # Any related identifiers known by the DMPTool
  related_identifiers = plan.related_identifiers.map { |r_id| r_id.clone }

  if plan.narrative_url.present?
    related_identifiers << RelatedIdentifier.new(relation_type: 'is_metadata_for', identifier_type: 'url',
                                                 work_type: 'output_management_plan', value: plan.narrative_url)
  end

  if related_identifiers.any?
    json.dmproadmap_related_identifiers related_identifiers do |related|
      next unless related.value.present? && related.relation_type.present?

      json.descriptor related.relation_type
      json.type related.identifier_type
      json.identifier related.value.start_with?('http') ? related.value : "https://doi.org/#{related.value}"
      json.work_type related.relation_type == 'is_metadata_for' ? 'output_management_plan' : related.work_type
    end
  end

  json.dmproadmap_privacy presenter.visibility

  # TODO: Refactor as we determine how best to fully implement sponsors
  if plan.template&.sponsor.present?
    json.dmproadmap_research_facilities [plan.template&.sponsor] do |sponsor|
      json.name sponsor.name
      json.type 'field_station'

      ror = sponsor.identifier_for_scheme(scheme: 'ror')
      if ror.present?
        json.facility_id do
          json.partial! 'api/v2/identifiers/show', identifier: ror
        end
      end
    end
  end

  # DMPHub extension to send all callback addresses for interested subscribers for changes to the DMP
  # json.dmphub_subscribers presenter.subscriptions
end

# DMPRoadmap specific links to perform special actions like downloading the PDF
json.dmproadmap_links presenter.links
