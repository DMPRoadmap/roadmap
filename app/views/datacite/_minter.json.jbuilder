# frozen_string_literal: true

json.ignore_nil!

# rubocop:disable Metrics/BlockLength
json.data do
  json.type "dois"

  json.attributes do
    json.prefix prefix
    json.schemaVersion "http://datacite.org/schema/kernel-4"

    json.types do
      json.resourceType "Text/Data Management Plan"
      json.resourceTypeGeneral "Text"
    end

    ror_scheme = IdentifierScheme.where(name: "ror").first
    fundref_scheme = IdentifierScheme.where(name: "fundref").first
    orcid_scheme = IdentifierScheme.where(name: "orcid").first

    creators = data_management_plan.owner_and_coowners

    if creators.present? && creators.any?
      json.creators creators do |creator|
        json.partial! "datacite/contributor", contributor: creator,
                                              orcid_scheme: orcid_scheme,
                                              ror_scheme: ror_scheme
      end
    end

    contributors = data_management_plan.contributors.to_a
    contributors << data_management_plan.org
    contributors << {
      name: Rails.configuration.x.datacite.hosting_institution,
      ror: Rails.configuration.x.datacite.hosting_institution_identifier
    }

    json.contributors contributors do |contributor|
      json.partial! "datacite/contributor", contributor: contributor,
                                            orcid_scheme: orcid_scheme,
                                            ror_scheme: ror_scheme
    end

    json.titles do
      json.array! [data_management_plan.title] do |title|
        json.title title
      end
    end
    json.publisher ApplicationService.application_name
    json.publicationYear Time.now.year

    json.dates [
      { type: "Created", date: data_management_plan.created_at.to_formatted_s(:iso8601) },
      { type: "Updated", date: data_management_plan.updated_at.to_formatted_s(:iso8601) }
    ] do |hash|
      json.date hash[:date]
      json.dateType hash[:type]
    end

    json.relatedIdentifiers [data_management_plan] do
      url = Rails.application.routes.url_helpers.api_v1_plan_url(data_management_plan)
      json.relatedIdentifier url
      json.relatedIdentifierType "URL"
      json.relatedIdentifierType "IsMetadataFor"
    end

    if data_management_plan.description.present?
      json.descriptions [data_management_plan.description] do |description|
        json.description description
        json.descriptionType "Abstract"
      end
    end

    if data_management_plan.funder.present?
      json.fundingReferences [data_management_plan.funder] do |funder|
        json.funderName funder.name

        fundref = creator.org.identifier_for_scheme(scheme: fundref_scheme)
        if fundref_scheme.present? && fundref.present?
          json.funderIdentifier fundref.value
          json.funderIdentifierType "Crossref Funder"
        end

        if data_management_plan.grant.present?
          if data_management_plan.grant.value.start_with?("http")
            json.awardURI = data_management_plan.grant.value
          end
          json.awardNumber = data_management_plan.grant.value
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
