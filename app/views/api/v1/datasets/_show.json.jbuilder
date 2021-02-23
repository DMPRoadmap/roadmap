# frozen_string_literal: true

# locals: output

if output.is_a?(ResearchOutput)
  presenter = Api::V1::ResearchOutputPresenter.new(output: output)

  json.type output.output_type
  json.title output.title
  json.description output.description
  json.personal_data Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: output.personal_data)
  json.sensitive_data Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: output.sensitive_data)
  json.issued output.release_date&.to_formatted_s(:iso8601)

  json.preservation_statement presenter.preservation_statement
  json.security_and_privacy presenter.security_and_privacy
  json.data_quality_assurance presenter.data_quality_assurance

  json.dataset_id do
    json.partial! "api/v1/identifiers/show", identifier: presenter.dataset_id
  end

  json.distribution output.repositories do |repository|
    json.title "Anticipated distribution for #{output.title}"
    json.byte_size output.byte_size
    json.data_access output.access

    json.host do
      json.title repository.name
      json.description repository.description
      json.url repository.url

      # DMPTool extensions to the RDA common metadata standard
      json.dmproadmap_host_id do
        json.partial! "api/v1/identifiers/show", identifier: repository.identifiers.last
      end
    end

    if output.license.present?
      json.license [output.license] do |license|
        json.license_ref license.url
        json.start_date presenter.license_start_date
      end
    end
  end

  json.metadata []

  json.technical_resource []

else
  json.type "dataset"
  json.title "Generic dataset"
  json.description "No individual datasets have been defined for this DMP."
end
