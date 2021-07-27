# frozen_string_literal: true

module Api

  module V1

    module Deserialization

      class Plan

        class << self

          # Convert the incoming JSON into a Plan
          #   {
          #     "dmp": {
          #       "created": "2020-03-26T11:52:00Z",
          #       "title": "Brain impairment caused by COVID-19",
          #       "description": "DMP for COVID-19 Brain analysis",
          #       "language": "eng",
          #       "ethical_issues_exist": "yes",
          #       "ethical_issues_description": "We will need to anonymize data",
          #       "ethical_issues_report": "https://university.edu/ethics/policy.pdf",
          #       "contact": {
          #         "$ref": "SEE Contributor.deserialize! for details"
          #       },
          #       "contributor": [{
          #         "$ref": "SEE Contributor.deserialize! for details"
          #       }],
          #       "project": [{
          #         "title": "Brain impairment caused by COVID-19",
          #         "description": "Brain stem comparisons of COVID-19 patients",
          #         "start": "2020-03-01T12:33:44Z",
          #         "end": "2023-03-31T12:33:44Z",
          #         "funding": [{
          #           "$ref": "SEE Funding.deserialize! for details"
          #         }]
          #       }],
          #       "dataset": [{
          #         "$ref": "SEE Dataset.deserialize! for details"
          #       }],
          #       "extension": [{
          #         "dmproadmap": {
          #           "template": {
          #             "id": 123,
          #             "title": "Generic Data Management Plan"
          #           }
          #         }
          #       }]
          #     }
          #   }
          def deserialize(json: {})
            return nil unless Api::V1::JsonValidationService.plan_valid?(json: json)

            json = json.with_indifferent_access
            # Try to find the Contributor or initialize a new one
            id_json = json.fetch(:dmp_id, {})
            plan = find_or_initialize(id_json: id_json, json: json)
            return nil unless plan.present? && plan.template.present?

            plan.description = json[:description] if json[:description].present?
            plan.ethical_issues = Api::V1::ConversionService.yes_no_unknown_to_boolean(json[:ethical_issues_exist])
            plan.ethical_issues_description = json[:ethical_issues_description]
            plan.ethical_issues_report = json[:ethical_issues_report]

            # Process Project, Contributors and Data Contact and Datsets
            plan = deserialize_project(plan: plan, json: json)
            # The contact is handled from within the controller since the Plan.add_user! method
            # requires that the Plan has been persisted to the DB
            plan = deserialize_contributors(plan: plan, json: json)
            deserialize_datasets(plan: plan, json: json)
          end

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          def find_or_initialize(id_json:, json: {})
            return nil unless json.present?

            id = id_json[:identifier] if id_json.is_a?(Hash)
            schm = IdentifierScheme.find_by(name: id_json[:type].downcase) if id.present?

            if id.present?
              # If the identifier is a DOI/ARK or the api client's internal id for the DMP
              if Api::V1::DeserializationService.doi?(value: id)
                # Find by the DOI or ARK
                plan = Api::V1::DeserializationService.object_from_identifier(
                  class_name: "Plan", json: id_json
                )
              elsif schm.present?
                value = id.start_with?(schm.identifier_prefix) ? id : "#{schm.identifier_prefix}#{id}"
                identifier = ::Identifier.find_by(
                  identifiable_type: "Plan", identifier_scheme: schm, value: value
                )
                plan = identifier.identifiable if identifier.present?
              else
                # For URL based identifiers
                begin
                  plan = ::Plan.find_by(id: id.split("/").last.to_i) if id.start_with("http")
                rescue StandardError
                  # Catches scenarios where the dmp_id is NOT one of our URLs
                  plan = nil
                end
              end
            end
            return plan if plan.present?

            template = find_template(json: json)
            plan = ::Plan.new(title: json[:title], template: template)
            return plan unless id.present? && schm.present?

            # If the external system provided an identifier and they have an IdentifierScheme
            Api::V1::DeserializationService.attach_identifier(object: plan, json: id_json)
          end

          # Deserialize the datasets and attach to plan
          def deserialize_datasets(plan:, json: {})
            return plan unless json.present? && json[:dataset].present? && json[:dataset].is_a?(Array)

            research_outputs = json[:dataset].map do |dataset|
              Api::V1::Deserialization::Dataset.deserialize(plan: plan, json: dataset)
            end

            # TODO: remove this once we support versioning and are not storing outputs with DOIs as
            #       RelatedIdentifiers. Once versioning is in place we can update the existing ResearchOutputs
            research_outputs.each do |output|
              plan.research_outputs << output if output.is_a?(ResearchOutput)
              plan.related_identifiers << output if output.is_a?(RelatedIdentifier)
            end
            plan
          end

          # Deserialize the project information and attach to Plan
          def deserialize_project(plan:, json: {})
            return plan unless json.present? &&
                               json[:project].present? &&
                               json[:project].is_a?(Array)

            project = json.fetch(:project, [{}]).first
            plan.start_date = Api::V1::DeserializationService.safe_date(value: project[:start])
            plan.end_date = Api::V1::DeserializationService.safe_date(value: project[:end])
            return plan unless project[:funding].present?

            funding = project.fetch(:funding, []).first
            return plan unless funding.present?

            Api::V1::Deserialization::Funding.deserialize(plan: plan, json: funding)
          end
          # rubocop:enable

          # Deserialize each Contributor and then add to Plan
          def deserialize_contributors(plan:, json: {})
            contributors = json.fetch(:contributor, []).map do |hash|
              Api::V1::Deserialization::Contributor.deserialize(json: hash)
            end
            plan.contributors << contributors.compact.uniq if contributors.any?
            plan
          end

          # Lookup the Template
          def find_template(json: {})
            default = Template.find_by(is_default: true)
            return default unless json.present? && json.fetch(:dmproadmap_template, {})[:id].present?

            template = Template.find_by(id: json.fetch(:dmproadmap_template, {})[:id].to_i)
            template.present? ? template : default
          end

        end

      end

    end

  end

end
