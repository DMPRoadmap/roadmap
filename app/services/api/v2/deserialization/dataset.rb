# frozen_string_literal: true

module Api
  module V2
    module Deserialization
      # Deserialization of RDA Common Standard for datasets to ResearchOutputs
      class Dataset
        class << self
          # rubocop:disable Layout/LineLength
          # Convert incoming JSON into a Dataset
          #    {
          #      "type": "dataset",
          #      "title": "My first test dataset",
          #      "description": "<p>This is going to be great!!!</p>",
          #      "personal_data": "unknown",
          #      "sensitive_data": "yes",
          #      "issued": "2022-05-13T00:00:00Z",
          #      "preservation_statement": "<strong>Question:</strong> Which data are of long-term value and should be retained, shared, and/or preserved?<br><strong>Answer:</strong> <p>I don't know.</p>\r\n<p>eebetbet</p><br><strong>Question:</strong> What is the long-term preservation plan for the dataset?<br><strong>Answer:</strong> <p>We will definitely do something.</p>\r\n<p>eebetbet</p>",
          #      "security_and_privacy": [
          #        {
          #          "title": "Ethics & privacy",
          #          "description": [
          #            "<strong>Question:</strong> Will your project involve sensitive data? Examples include: <span style=\"font-weight: 400;\">traditional knowledge, archeological artifacts, endangered species, medical data, and human subject research.</span><br><strong>Answer:</strong> <p>Probably.</p>\r\n<p>Time will tell.</p>",
          #            "<strong>Question:</strong> How will you manage access and security?<br><strong>Answer:</strong> <p>Very carefully.</p>",
          #          ]
          #        },
          #      ],
          #      "data_quality_assurance": "<strong>Question:</strong> How will the data be collected or created?<br><strong>Answer:</strong> <p>Through various instruments.</p><br><strong>Question:</strong> What standards and methodologies will be utilized for data collection and management?<br><strong>Answer:</strong> <p>Only the best.</p>",
          #      "dataset_id": { "type": "other", "identifier": "1" },
          #      "distribution": [
          #        {
          #          "title": "Anticipated distribution for My first test dataset",
          #          "byte_size": 60129542144,
          #          "data_access": "open",
          #          "host": {
          #            "title": "Example Repository",
          #            "description": "The example repository is for DMPTool testing",
          #            "url": "https://example.org/repo",
          #            "dmproadmap_host_id": { "type": "url", "identifier": "https://www.re3data.org/api/v1/repository/r3d10000XXXX" }
          #          },
          #          "license": [
          #            {
          #              "license_ref": "http://spdx.org/licenses/Artistic-1.0.json",
          #              "start_date": "2022-05-13T00:00:00Z"
          #            }
          #          ]
          #        }
          #      ],
          #      "metadata": [
          #        {
          #          "description": "Dublin Core - A basic, domain-agnostic standard which can be easily understood ...",
          #          "metadata_standard_id": { "type": "url", "identifier": "https://rdamsc.bath.ac.uk/api2/m15" }
          #        }
          #      ],
          #      "technical_resource": []
          #    }
          # rubocop:enable Layout/LineLength

          # rubocop:disable Metrics/AbcSize
          def deserialize(plan:, json: {})
            return nil unless Api::V2::JsonValidationService.dataset_valid?(json: json)

            json = json.with_indifferent_access
            # Try to find the Dataset or initialize a new one
            research_output = find_by_identifier(plan: plan, json: json[:dataset_id])
            # TODO: remove this once we support versioning and are not storing these as RelatedIdentifiers
            return research_output if research_output.is_a?(RelatedIdentifier)

            research_output = find_or_initialize(plan: plan, json: json) if research_output.blank?
            return nil unless research_output.present? && research_output.title.present?

            research_output.description = json[:description] if json[:description].present?
            research_output.personal_data = Api::V2::ConversionService.yes_no_unknown_to_boolean(json[:personal_data])
            research_output.sensitive_data = Api::V2::ConversionService.yes_no_unknown_to_boolean(json[:sensitive_data])
            research_output.release_date = Api::V2::DeserializationService.safe_date(value: json.fetch(:issued,
                                                                                                       Time.zone.now))

            research_output = attach_metadata(research_output: research_output, json: json[:metadata])
            deserialize_distribution(research_output: research_output, json: json[:distribution])
          end
          # rubocop:enable Metrics/AbcSize

          private

          def find_by_identifier(plan:, json:)
            return nil unless json.is_a?(Hash) && json[:identifier].present?

            # Find by identifier if its available
            id = json[:identifier]
            if id.present?
              if Api::V2::DeserializationService.dmp_id?(value: id)
                # Find by the DOI or ARK
                # TODO: Swap this out once we support versioning which will allow us to update
                #       the actual ResearchOutput metadata. For now we will record it as a RelatedIdentifier
                #
                # research_output = Api::V2::DeserializationService.object_from_identifier(
                #   class_name: "ResearchOutput", json: json
                # )
                id = id.start_with?('http') ? id : "http://doi.org/#{id.gsub('doi:', '')}"
                research_output = ::RelatedIdentifier.find_or_initialize_by(
                  identifiable: plan,
                  identifier_type: 'doi',
                  relation_type: 'is_referenced_by',
                  value: id
                )
              else
                research_output = ::ResearchOutput.find_by(plan: plan, id: id)
              end
            end
            research_output
          end

          # Find the dateset by ID or title + plan
          def find_or_initialize(plan:, json: {})
            return nil if json.blank?

            research_output = ::ResearchOutput.find_or_initialize_by(title: json[:title], plan: plan)
            research_output.research_output_type = json[:type] || 'dataset' if research_output.new_record?

            Api::V2::DeserializationService.attach_identifier(object: research_output, json: json[:dataset_id])
          end

          # Add any metadata standards
          def attach_metadata(research_output:, json:)
            return research_output unless json.is_a?(Array)

            json.select { |h| h.fetch(:metadata_standard_id, {})[:identifier].present? }.each do |hash|
              # Try to find the MetadataStandard by the identifier
              metadata_standard = ::MetadataStandard.find_by(
                uri: hash[:metadata_standard_id][:identifier], description: hash[:description]
              )
              next if metadata_standard.nil? || research_output.metadata_standards.include?(metadata_standard)

              research_output.metadata_standards << metadata_standard
            end
            research_output
          end

          # Add any distribution level data to the research output
          def deserialize_distribution(research_output:, json:)
            return research_output unless research_output.present? && json.is_a?(Array)

            json.each do |distribution|
              # Try to locate the hosts from our list of Repositories
              research_output = attach_repositories(research_output: research_output, json: distribution[:host])
              research_output = attach_licenses(research_output: research_output, json: distribution[:license])
              research_output.byte_size = distribution[:byte_size]
              research_output.access = distribution[:data_access]
            end
            research_output
          end

          # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def attach_repositories(research_output:, json:)
            return research_output unless research_output.present? && json.is_a?(Hash)

            uri = json.fetch(:dmproadmap_host_id, {})[:identifier]
            if json[:url].present? || uri.present?
              repository = ::Repository.find_by(uri: uri) if uri.present?
              repository = ::Repository.find_by(homepage: json[:url]) if repository.blank?
              return research_output if repository.nil? ||
                                        research_output.repositories.include?(repository)

              research_output.repositories << repository
            end
            research_output
          end
          # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # rubocop:disable Metrics/AbcSize
          def attach_licenses(research_output:, json:)
            return research_output unless research_output.present? && json.is_a?(Array)

            # Attempt to grab the current license
            licenses = json.sort_by { |a| a[:start_date] }
            prior_licenses = licenses.select do |license|
              date = Api::V2::DeserializationService.safe_date(value: license[:start_date])
              date <= Time.zone.now
            end

            # If there are no current licenses then just grab the first one
            license = prior_licenses.any? ? prior_licenses.last : json.first
            license = License.find_by(uri: license[:license_ref])

            research_output.license = license if license.present?
            research_output
          end
          # rubocop:enable Metrics/AbcSize
        end
      end
    end
  end
end
