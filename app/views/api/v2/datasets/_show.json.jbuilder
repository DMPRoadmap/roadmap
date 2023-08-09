# frozen_string_literal: true

# locals: output

if output.is_a?(ResearchOutput)
  presenter = Api::V1::ResearchOutputPresenter.new(output: output)

  json.type presenter.research_output_type
  json.title output.title

  # Remove non breaking spaces, empty paragraphs and new lines
  json.description output.description&.gsub(/\u00a0/, '')&.gsub(%r{<p>([\s]+)?</p>}, '')&.gsub(%r{[\r\n]+}, ' ')

  json.personal_data Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: output.personal_data)
  json.sensitive_data Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: output.sensitive_data)
  json.issued output.release_date&.to_formatted_s(:iso8601)

  json.preservation_statement presenter.preservation_statement
  json.data_quality_assurance [presenter.data_quality_assurance]

  if presenter.security_and_privacy.present?
    json.security_and_privacy [presenter.security_and_privacy] do |stmt|
      json.title 'Security and Privacy'
      json.description stmt
    end
  end

  json.dataset_id do
    json.partial! 'api/v2/identifiers/show', identifier: presenter.dataset_id
  end

  json.distribution output.repositories do |repository|
    json.title "Anticipated distribution for #{output.title}"
    json.byte_size output.byte_size
    json.data_access presenter.converted_access(data_access: output.access)

    json.host do
      json.title repository.name

      # Remove non breaking spaces, empty paragraphs and new lines
      json.description repository.description&.gsub(/\u00a0/, '')&.gsub(%r{<p>([\s]+)?</p>}, '')&.gsub(%r{[\r\n]+}, ' ')
      json.url repository.homepage

      # DMPTool extensions to the RDA common metadata standard
      json.dmproadmap_host_id do
        json.type 'url'
        json.identifier repository.uri
      end
    end

    if output.license.present? && output.license.uri.present?
      json.license [output.license] do |license|
        json.license_ref license.uri
        json.start_date presenter.license_start_date
      end
    end
  end

  json.metadata output.metadata_standards do |metadata_standard|
    website = metadata_standard.locations&.find { |loc| loc['type'] == 'website' }
    website = { url: metadata_standard.uri } if website.blank?

    descr_array = [metadata_standard.title, metadata_standard.description, website['url']]

    # Remove non breaking spaces, empty paragraphs and new lines
    json.description descr_array.join(' - ')&.gsub(/\u00a0/, '')&.gsub(%r{<p>([\s]+)?</p>}, '')&.gsub(%r{[\r\n]+}, ' ')

    json.metadata_standard_id do
      json.type 'url'
      json.identifier metadata_standard.uri
    end
  end

  json.technical_resource []

  if output.plan.research_domain_id.present?
    research_domain = ResearchDomain.find_by(id: output.plan.research_domain_id)
    if research_domain.present?
      combined = "#{research_domain.identifier} - #{research_domain.label}"
      json.keyword [research_domain.label, combined]
    end
  end

else
  json.type 'dataset'
  json.title 'Generic dataset'
  json.description 'No individual datasets have been defined for this DMP.'

  if output.research_domain_id.present?
    research_domain = ResearchDomain.find_by(id: output.research_domain_id)
    if research_domain.present?
      combined = "#{research_domain.identifier} - #{research_domain.label}"
      json.keyword [research_domain.label, combined]
    end
  end
end
