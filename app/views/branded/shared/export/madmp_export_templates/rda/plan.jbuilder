# frozen_string_literal: true

meta = dmp.meta
project = dmp.project
research_outputs = dmp.research_outputs

json.prettify!

json.dmp do 

  json.created          DateTime.iso8601(meta.data["creationDate"]).strftime("%FT%T")
  json.description      strip_tags(meta.data["description"])
  json.dmp_id do
    json.identifier     meta.data["dmpId"] || dmp.data["plan_id"]
    json.type           meta.data["dmpId"] ? meta.data["idType"] : "Internal identifier"
  end
  json.language                   meta.data["dmpLanguage"]
  json.modified                   DateTime.iso8601(meta.data["lastModifiedDate"]).strftime("%FT%T")
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
  json.contributor  dmp.persons do |person|
    json.name       person.to_s
    json.mbox       person.data["mbox"]
    json.role       person.roles
    json.contributor_id do 
      json.identifier     person.data["personId"]
      json.type           person.data["idType"]
    end
  end
  json.cost         dmp.costs do |cost| 
    json.currency_code      cost.data["currency"]
    json.description        strip_tags(cost.data["description"])
    json.title              cost.data["title"]
    json.value              cost.data["amount"]
  end
  json.project do
    start_date = project.data["startDate"] ? DateTime.iso8601(project.data["startDate"]).strftime("%FT%T") : nil
    end_date = project.data["endDate"] ? DateTime.iso8601(project.data["endDate"]).strftime("%FT%T") : nil
    
    json.description      strip_tags(project.data["description"])
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
        json.type           _("Other")
      end
    end
  end
  json.partial! "shared/export/madmp_export_templates/rda/datasets",
                datasets: research_outputs, selected_datasets: selected_research_outputs
end