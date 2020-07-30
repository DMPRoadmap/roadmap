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

    creators = data_management_plan.owner_and_coowners
    ror_scheme = IdentifierScheme.where(name: "ror").first
    orcid_scheme = IdentifierScheme.where(name: "orcid").first

    if creators.present? && creators.any?
      json.creators creators do |creator|
        json.name [creator.surname, creator.firstname].join(", ")
        json.nameType "Personal"

        if creator.org.present?
          json.affiliation do
            json.name creator.org.name

            ror = creator.org.identifier_for_scheme(scheme: ror_scheme)
            if ror_scheme.present? && ror.present?
              json.affiliationIdentifier ror.value
              json.affiliationIdentifierScheme "ROR"
            end
          end
        end

        orcid = creator.identifier_for_scheme(scheme: orcid_scheme)
        if orcid_scheme.present? && orcid.present?
          json.nameIdentifiers [orcid] do |ident|
            json.schemeUri "https://orcid.org"
            json.nameIdentifier "https://orcid.org/#{ident.value}"
            json.nameIdentifierScheme "ORCID"
          end
        end
      end
    end

    contributors = data_management_plan.contributors
    if contributors.present? && contributors.any?
      json.contributors contributors do |contributor|
        next unless contributor.roles.positive?

        datacite_role = "ProjectManager" if contributor.project_administration?
        datacite_role = "ProjectLeader" if datacite_role.nil? && contributor.investigation?
        datacite_role = "DataCurator" unless datacite_role.present?

        json.name contributor.name
        json.nameType "Personal"
        json.contributorType datacite_role

        if contributor.org.present?
          json.affiliation do
            json.name contributor.org.name

            ror = contributor.org.identifier_for_scheme(scheme: ror_scheme)
            if ror_scheme.present? && ror.present?
              json.affiliationIdentifier ror.value
              json.affiliationIdentifierScheme "ROR"
            end
          end
        end

        orcid = contributor.identifier_for_scheme(scheme: orcid_scheme)
        if orcid_scheme.present? && orcid.present?
          json.nameIdentifiers [orcid] do |ident|
            json.schemeUri "https://orcid.org"
            json.nameIdentifier "https://orcid.org/#{ident.value}"
            json.nameIdentifierScheme "ORCID"
          end
        end
      end
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

        ror = creator.org.identifier_for_scheme(scheme: ror_scheme)
        if ror_scheme.present? && ror.present?
          json.funderIdentifier ror.value
          json.funderIdentifierType "ROR"
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
