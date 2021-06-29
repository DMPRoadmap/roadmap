# frozen_string_literal: true

meta = dmp.meta
project = dmp.project
research_outputs = dmp.research_outputs

json.prettify!

json.created          meta.data["creationDate"]
json.description      meta.data["description"]
json.dmp_id do
  json.identifier     meta.data["dmpId"] || dmp.data["plan_id"]
  json.type           meta.data["idType"]
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
json.contributor  format_contributors(dmp)
json.cost         dmp.costs do |cost| 
  json.currency_code      cost.data["currency"]
  json.description        cost.data["description"]
  json.title              cost.data["title"]
  json.value              cost.data["amount"]
end
json.project do
  json.description      project.data["description"]
  json.title            project.data["title"]
  json.start            project.data["startDate"]
  json.end              project.data["endDate"]
  json.funding project.fundings do |funding|
    json.funder_id do
      json.identifier     funding.funder.data["funderId"]
      json.type           funding.funder.data["idType"]
    end
    json.funding_status funding.data["fundingStatus"]
    json.grant_id do
      json.identifier     funding.data["grantId"]
      json.type           "None"
    end
  end
end
json.partial! "shared/export/madmp_export_templates/rda/datasets", datasets: research_outputs