json.prettify!

json.plans @org_plans.each do |plan|
  json.id             plan.id
  json.grant_number   plan.grant_number
  json.org_id         plan.owner.org.id
  json.template do
    json.title        plan.template.title
    json.id           plan.template.id
  end
  json.project do
    json.title        plan.title
  end
  json.funder do
    json.name         (plan.template.org.funder? ? plan.template.org.name : '')
  end
  json.principal_investigator do
    json.name         plan.principal_investigator
  end
  json.data_contact do
    json.info         plan.data_contact
  end
  json.description    plan.description

end