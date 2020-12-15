# locals: contributor, orcid_scheme, ror_scheme

if contributor.is_a?(Hash)
  if contributor[:name].present?
    json.name contributor[:name]
    json.nameType "Organizational"
    json.contributorType "HostingInstitution"

    if contributor[:ror].present?
      json.nameIdentifier contributor[:ror]
      json.nameIdentifierScheme "ROR"
    end
  end

elsif contributor.is_a?(Org)
  json.name contributor.name
  json.nameType "Organizational"

  json.contributorType "Producer"

  ror = contributor.identifier_for_scheme(scheme: ror_scheme)
  if ror_scheme.present? && ror.present?
    json.nameIdentifier ror.value
    json.nameIdentifierScheme "ROR"
  end

else
  if contributor.is_a?(User)
    json.name [contributor.surname, contributor.firstname].join(", ")
  elsif contributor.is_a?(Contributor) && contributor.roles.positive?
    json.name contributor.name

    datacite_role = "ProjectManager" if contributor.project_administration?
    datacite_role = "ProjectLeader" if datacite_role.nil? && contributor.investigation?
    datacite_role = "DataCurator" unless datacite_role.present?
    json.contributorType datacite_role
  end

  json.nameType "Personal"

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
    json.nameIdentifiers [orcid] do
      json.nameIdentifier "https://orcid.org/#{orcid.value}"
      json.nameIdentifierScheme "ORCID"
    end
  end
end
