# frozen_string_literal: true

module Api

  module V1

    module Deserialization

      # rubocop:disable Metrics/ClassLength
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
          # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          def deserialize!(json: {})
            return nil unless json.present? && valid?(json: json)

            json = json.with_indifferent_access
            plan = marshal_plan(json: json)
            return nil unless plan.present?

            plan.title = json[:title]
            plan.description = json[:description] if json[:description].present?
            plan.save

            # TODO: Handle ethical issues when the Question is in place

            # Process Project, Contributors and Data Contact and Datsets
            plan = deserialize_project(plan: plan, json: json)
            plan = deserialize_contact(plan: plan, json: json)
            plan = deserialize_contributors(plan: plan, json: json)
            plan = deserialize_datasets(plan: plan, json: json)

            plan
          end
          # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          # Quickly determine whether or not the JSON contains enough information
          # to marshal the Plan and its dependencies
          def valid?(json: {})
            return false unless json.present? &&
                                json[:title].present? &&
                                json[:contact].present? &&
                                json[:contact][:mbox].present?

            # We either need a Template.id (creating) or a Plan.id (updating)
            dmp_id = json[:dmp_id]&.fetch(:identifier, nil)
            template_id(json: json).present? || dmp_id.present?
          end

          # Find or initialize the Plan
          def marshal_plan(json: {})
            plan = find_by_identifier(json: json)
            return plan if plan.present?

            # If this is not an existing Plan, then initialize a new one
            # for the specified template (or the default template if none specified)
            template = find_template(json: json)
            return nil unless template.present?

            ::Plan.new(template_id: template.id)
          end

          # Deserialize the datasets and attach to plan
          # TODO: Implement this once we update the data model
          def deserialize_datasets(plan:, json: {})
            return plan unless json.present? && json[:dataset].present?

            plan
          end

          # Deserialize the project information and attach to Plan
          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def deserialize_project(plan:, json: {})
            return plan unless json.present? &&
                               json[:project].present? &&
                               json[:project].is_a?(Array)

            project = json.fetch(:project, [{}]).first
            plan.start_date = Time.new(project[:start]).utc if project[:start].present?
            plan.end_date = Time.new(project[:end]).utc if project[:end].present?
            return plan unless project[:funding].present?

            funding = project.fetch(:funding, []).first
            return plan unless funding.present?

            Api::V1::Deserialization::Funding.deserialize!(plan: plan, json: funding)
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          # rubocop:enable Metrics/AbcSize

          # Deserialize the contact as a Contributor
          def deserialize_contact(plan:, json: {})
            return plan unless json.present? && json[:contact].present?

            contact = Api::V1::Deserialization::Contributor.deserialize!(
              plan_id: plan.id, json: json[:contact], is_contact: true
            )
            return plan unless contact.present?

            contact.save
            plan.contributors << contact
            plan.org = contact.org
            plan
          end

          # Deserialize each Contributor and then add to Plan
          def deserialize_contributors(plan:, json: {})
            contributors = json.fetch(:contributor, []).map do |hash|
              Api::V1::Deserialization::Contributor.deserialize!(
                plan_id: plan.id, json: hash
              )
            end
            plan.contributors << contributors.compact.uniq if contributors.any?
            plan
          end

          # Locate the Org by its identifier
          # rubocop:disable Metrics/AbcSize
          def find_by_identifier(json: {})
            return nil unless json.present? && json[:dmp_id].present? &&
                              json[:dmp_id][:identifier].present?

            id = json[:dmp_id][:identifier]
            if doi?(value: id)
              # Find by the DOI or ARK
              ::Plan.from_identifiers(
                array: [{ name: json[:dmp_id][:type], value: json[:dmp_id][:identifier] }]
              )
            else
              # For URL based identifiers
              ::Plan.find_by(id: id.split("/").last)
            end
          end
          # rubocop:enable Metrics/AbcSize

          # Determine whether or not the value is a DOI or ARK
          def doi?(value:)
            return false unless value.present?

            # The format must match a DOI or ARK and a DOI IdentifierScheme
            # must also be present!
            identifier = ::Identifier.new(value: value)
            scheme = ::IdentifierScheme.find_by(name: "doi")
            %w[ark doi].include?(identifier.identifier_format) && scheme.present?
          end

          # Lookup the Template
          def find_template(json: {})
            return nil unless json.present?

            template = ::Template.find_by(id: template_id(json: json))
            template.present? ? template : Template.find_by(is_default: true)
          end

          # Extract the Template id from the JSON
          def template_id(json: {})
            return nil unless json.present?

            extensions = app_extensions(json: json)
            return nil unless extensions.present?

            extensions.fetch(:template, {})[:id]
          end

          # Retrieve the extensions to the JSON for this application
          # rubocop:disable Metrics/AbcSize
          def app_extensions(json: {})
            return {} unless json.present? && json[:extension].present?

            app = ::ApplicationService.application_name.split("-").first
            ext = json[:extension].select { |item| item[app.to_sym].present? }
            ext.first.present? ? ext.first[app.to_sym] : {}
          end
          # rubocop:enable Metrics/AbcSize

        end

      end
      # rubocop:enable Metrics/ClassLength

    end

  end

end
