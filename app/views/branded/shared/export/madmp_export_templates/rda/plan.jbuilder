# frozen_string_literal: true

meta = dmp.meta
project = dmp.project
research_outputs = dmp.research_outputs

json.prettify!

# rubocop:disable Metrics/BlockLength
json.dmp do
  json.created          meta.data["creationDate"]
  json.description      exportable_description(meta.data["description"])
  json.dmp_id do
    json.identifier     meta.data["dmpId"] || plan_url(id: dmp.data["plan_id"])
    json.type           meta.data["dmpId"] ? meta.data["idType"] : "URL"
  end
  json.language                   meta.data["dmpLanguage"]
  json.modified                   meta.data["lastModifiedDate"]
  json.title                      meta.data["title"]

  contact = meta.contact
  json.contact do
    json.contact_id do
      json.identifier     contact.person.data["personId"]
      json.type           contact.person.data["idType"]
    end
    json.mbox   contact.person.data["mbox"]
    json.name   contact.person.to_s
  end
  json.contributor dmp.persons do |person|
    roles = person.roles(selected_research_outputs)
    next if roles.empty?

    json.name       person.to_s
    json.mbox       person.data["mbox"]
    json.role       roles.uniq
    json.contributor_id do
      json.identifier     person.data["personId"]
      json.type           person.data["idType"]
    end
  end
  json.cost         dmp.costs do |cost|
    json.currency_code      cost.data["currency"]
    json.description        exportable_description(cost.data["description"]) || cost.data["costType"]
    json.title              cost.data["title"]
    json.value              cost.data["amount"]
  end
  json.project do
    start_date = project.data["startDate"] || nil
    end_date = project.data["endDate"] || nil
    json.description      exportable_description(project.data["description"])
    json.title            project.data["title"]
    json.start            start_date
    json.end              end_date
    json.funding project.fundings do |funding|
      json.funder_id do
        json.identifier     funding.funder.data["funderId"]
        json.type           funding.funder.data["idType"]
      end
      json.funding_status funding.data["fundingStatus"]
      json.grant_id do
        json.identifier     funding.data["grantId"]
        json.type           "Code"
      end
    end
  end
  json.partial! "shared/export/madmp_export_templates/rda/datasets",
                datasets: research_outputs, selected_datasets: selected_research_outputs
end
# rubocop:enable Metrics/BlockLength
