# frozen_string_literal: true

# builds a json response to a successful project createtion

json.prettify!

# rubocop:disable Metrics/BlockLength
json.array! @plans.each do |plan|
  json.id             plan.id
  json.title          plan.title
  json.grant_number   plan.grant_number
  json.last_updated   plan.updated_at
  json.creation_date  plan.created_at
  json.test_plan      plan.is_test?
  json.template do
    json.title        plan.template.title
    json.id           plan.template.family_id
  end
  json.funder do
    json.name(plan.template.org.funder? ? plan.template.org.name : plan.funder&.name)
  end
  json.principal_investigator do
    investigator = plan.contributors.investigation.first

    json.name         investigator.name
    json.email        investigator.email
    json.phone        investigator.phone
  end

  json.data_contact do
    data_contact = plan.contributors.data_curation.first
    json.name         data_contact.name
    json.email        data_contact.email
    json.phone        data_contact.phone
  end
  json.users plan.roles.each do |role|
    json.email role.user.email
  end
  json.description plan.description
  json.plan_content plan.template.phases.each do |phase|
    json.title phase.title
    json.description phase.description
    json.sections phase.sections.each do |section|
      json.title        section.title
      json.description  section.description
      json.number       section.number
      json.questions section.questions.each do |question|
        json.text       question.text
        json.number     question.number
        json.format     question.question_format.title
        json.option_based question.question_format.option_based
        json.themes question.themes.each do |theme|
          json.theme theme.title
        end
        answer = plan.answers.select { |a| a.question_id == question.id }.first
        if answer.present?
          json.answered true
          json.answer do
            json.text answer.text
            if answer.question_options.present?
              json.options answer.question_options.each do |option|
                json.text option.text
              end
            end
          end
        else
          json.answered false
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
