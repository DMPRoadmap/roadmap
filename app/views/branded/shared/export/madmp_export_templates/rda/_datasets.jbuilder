# frozen_string_literal: true

ethical_issues_exist = []
ethical_issues_description = []
ethical_issues_report = []

# rubocop:disable Metrics/BlockLength
json.dataset datasets do |dataset|
  next unless selected_datasets.include?(dataset.data["research_output_id"])

  dataset_title = dataset.research_output_description.data["title"]
  json.dataset_id do
    json.identifier     dataset.data["research_output_id"]
    json.type           "Internal indentifier"
  end
  json.description                dataset.research_output_description.data["description"]
  json.keyword                    dataset.research_output_description.data["uncontrolledKeywords"]
  json.language                   dataset.research_output_description.data["language"]
  json.personal_data              dataset.research_output_description.data["containsPersonalData"]
  if dataset.preservation_issues.present?
    json.preservation_statement     dataset.preservation_issues.data["description"]
  else
    json.preservation_statement     ""
  end
  json.title                      dataset_title
  json.type                       dataset.research_output_description.data["type"]
  json.sensitive_data             dataset.research_output_description.data["containsSensitiveData"]
  if dataset.sharing.present?
    # json.issued               dataset.sharing.distribution.data["releaseDate"]
    json.issued ""
    json.distribution dataset.sharing.distribution do |distribution|
      json.access_url         distribution.data["accessUrl"]
      json.available_until    distribution.data["availableUntil"]
      json.data_access        distribution.data["fileVolume"]
      json.access_url         distribution.data["dataAccess"]
      json.description        distribution.data["description"]
      json.download_url       distribution.data["downloadUrl"]
      json.format             distribution.data["fileFormat"]
      json.title              distribution.data["fileName"]
      if distribution.sharing.host.present?
        host = distribution.sharing.host
        json.host do
          json.description            host.data["description"]
          json.availability           host.data["availability"]
          json.certified_with         host.data["certification"]
          json.geo_location           host.data["geoLocation"]
          json.pid_system             host.data["pidSystem"]
          json.support_versioning     host.data["hasVersioningPolicy"]
          json.title                  host.data["title"]
          json.url                    host.data["hostId"]
          json.license_ref            distribution.license.data["licenseUrl"]
          json.start_date             distribution.data["licenseStartDate"]
        end
      else
        json.host {}
      end
    end
  else
    json.distribution []
  end

  if dataset.documentation_quality.present?
    json.data_quality_assurance dataset.documentation_quality.data["description"]
    json.metadata dataset.documentation_quality.metadata_standard do |metadata_standard|
      json.description        "#{metadata_standard.data['name']} - #{metadata_standard.data['description']}"
      json.language           metadata_standard.data["metadataLanguage"]
      json.metadata_standard_id do 
        json.identifier metadata_standard.data["metadataStandardId"]
        json.type       metadata_standard.data["IdType"]
      end
    end
  else
    json.metadata []
  end

  if dataset.data_storage.present?
    json.security_and_privacy do
      json.description        dataset.data_storage.data["securityMeasures"]
      json.language           "Security measures"
    end
  else
    json.security_and_privacy {}
  end
  json.technical_resource []

  ethical_issues_exist.push("#{dataset_title} : #{dataset.research_output_description.data['hasEthicalIssues']}")
  if dataset.ethical_issues.present?
    ethical_issues_description.push("#{dataset_title} : #{dataset.ethical_issues.data['description']}")
    ethical_issues_report.push(
      "#{dataset_title} : #{dataset.ethical_issues.resource_reference.pluck("data->'docIdentifier'").join(', ')}"
    )
  end
end
# rubocop:enable Metrics/BlockLength
json.ethical_issues_exist         ethical_issues_exist.join(" / ")
json.ethical_issues_description   ethical_issues_description.join(" / ")
json.ethical_issues_report        ethical_issues_report.join(" / ")
