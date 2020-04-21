# frozen_string_literal: true

# locals: org

json.name org.name
json.abbreviation org.abbreviation
json.region org.region&.abbreviation

if org.identifiers.any?
  json.affiliation_id do
    id = Api::V1::OrgPresenter.affiliation_id(identifiers: org.identifiers)
    json.partial! "api/v1/identifiers/show", identifier: id
  end
end
