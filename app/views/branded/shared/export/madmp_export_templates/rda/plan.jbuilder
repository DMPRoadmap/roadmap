# frozen_string_literal: true

meta = dmp.meta
project = dmp.project
research_outputs = dmp.plan.research_outputs.order(:display_order)

json.prettify!

# rubocop:disable Metrics/BlockLength
json.dmp do
  json.created          Export::Converters::RdaRegistryConverter.convert_date_to_iso8601(meta.data["creationDate"])
  json.description      exportable_description(meta.data["description"])
  json.dmp_id do
    json.identifier     meta.data["dmpId"] || plan_url(id: dmp.data["plan_id"])
    json.type           Export::Converters::RdaRegistryConverter.convert_pid_system(
      meta.data["dmpId"] ? meta.data["idType"] : "URL"
    )
  end
  json.language meta.data["dmpLanguage"]
  json.modified Export::Converters::RdaRegistryConverter.convert_date_to_iso8601(meta.data["lastModifiedDate"])
  json.title meta.data["title"]

  contact = meta.contact
  if contact.present?
    json.contact do
      json.contact_id do
        json.identifier     contact.person.data["personId"]
        json.type           Export::Converters::RdaRegistryConverter.convert_agent_id_system(
          contact.person.data["idType"], is_person: true
        )
      end
      json.mbox   contact.person.data["mbox"]
      json.name   contact.person.to_s
    end
  else
    json.contact({})
  end
  json.contributor dmp.persons do |person|
    roles = person.roles(selected_research_outputs)
    next if roles.empty?

    json.name       person.to_s
    json.mbox       person.data["mbox"]
    json.role       roles.uniq
    json.contributor_id do
      json.identifier     person.data["personId"]
      json.type           Export::Converters::RdaRegistryConverter.convert_agent_id_system(person.data["idType"],
                                                                                           is_person: true)
    end
  end
  json.cost dmp.costs do |cost|
    json.currency_code      cost.data["currency"]
    json.description        exportable_description(cost.data["description"]) || cost.data["costType"]
    json.title              cost.data["title"]
    json.value              cost.data["amount"]
  end
  json.project do
    json.child! do
      start_date = project.data["startDate"] || nil
      end_date = project.data["endDate"] || nil
      json.description      exportable_description(project.data["description"])
      json.title            project.data["title"]
      json.start            start_date
      json.end              end_date
      json.funding project.fundings do |funding|
        json.funder_id do
          json.identifier     funding.funder.data["funderId"]
          json.type           Export::Converters::RdaRegistryConverter.convert_agent_id_system(
            funding.funder.data["idType"]
          )
        end
        json.funding_status Export::Converters::RdaRegistryConverter.convert_funding_status(
          funding.data["fundingStatus"]
        )
        json.grant_id do
          json.identifier     funding.data["grantId"]
          json.type           'other'
        end
      end
    end
  end
  json.partial! "shared/export/madmp_export_templates/rda/datasets",
                plan: dmp.plan, research_outputs: research_outputs, selected_datasets: selected_research_outputs
end
# rubocop:enable Metrics/BlockLength
