# frozen_string_literal: true

# rubocop:disable Naming/VariableNumber
namespace :dmpopidor_upgrade do
  desc 'Upgrade to 2.1.0'
  task v2_1_0: :environment do
    Rake::Task['dmpopidor_upgrade:add_themes_token_permission_types'].execute
    Rake::Task['dmpopidor_upgrade:grant_themes_api_to_all_orgs'].execute
    Rake::Task['dmpopidor_upgrade:grant_api_to_all_orgs'].execute
    Rake::Task['dmpopidor_upgrade:create_number_field'].execute
  end

  desc 'Upgrade to 2.2.0'
  task v2_2_0: :environment do
    Rake::Task['dmpopidor_upgrade:create_research_output_types'].execute
    Rake::Task['dmpopidor_upgrade:research_outputs_enable'].execute
  end

  desc 'Upgrade to 2.3.0'
  task v2_3_0: :environment do
    Rake::Task['dmpopidor_upgrade:close_existing_feedback_plans'].execute
  end

  desc 'Add the themes token permission type'
  task add_themes_token_permission_types: :environment do
    if TokenPermissionType.find_by(token_type: 'themes').nil?
      TokenPermissionType.create!({ token_type: 'themes',
                                    text_description: 'allows a user access to the themes api endpoint' })
    end
  end

  desc 'Grant themes API to all orgs'
  task grant_themes_api_to_all_orgs: :environment do
    orgs = Org.where(is_other: false).select(:id) + Org.where(is_other: nil).select(:id)
    orgs.each do |org|
      org.grant_api!(TokenPermissionType.where(token_type: 'themes'))
    end
  end

  desc 'Grant all API to all orgs'
  task grant_api_to_all_orgs: :environment do
    orgs = Org.where(is_other: false).select(:id) + Org.where(is_other: nil).select(:id)
    orgs.each do |org|
      org.grant_api!(TokenPermissionType.where(token_type: 'guidances'))
      org.grant_api!(TokenPermissionType.where(token_type: 'plans'))
      org.grant_api!(TokenPermissionType.where(token_type: 'templates'))
      org.grant_api!(TokenPermissionType.where(token_type: 'statistics'))
    end
  end

  desc 'Create number field'
  task create_number_field: :environment do
    if QuestionFormat.find_by(title: 'Number').nil?
      QuestionFormat.create!({ title: 'Number', option_based: false, formattype: 8 })
    end
  end

  # Migrates the database to use research_outputs
  # - Adds a research output table to the base (via the above migrations)
  # - Creates a default research output for every plan
  # - Moves all plans' answers to their new default research output
  desc 'Migrate the database to use research outputs'
  task research_outputs_enable: :environment do
    # Apply migration

    # Create research outputs and move answers
    Plan.all.each do |p|
      research_output = if p.research_outputs.empty?
                          p.research_outputs.create(
                            abbreviation: 'Default',
                            fullname: 'Default research output',
                            is_default: true,
                            type: ResearchOutputType.find_by(label: 'Dataset'),
                            order: 1
                          )
                        end

      p.answers.each { |a| a.update_column(:research_output_id, research_output.id) }
    end
  end

  # Rollback for the database migration enable the research outputs
  # - Remove all non default research outputs and their answers
  # - 'Detach' remaining answers from their research outputs (the default ones)
  # - Drop the research outputs table and reverse the migrations
  desc 'Migrate the database to remove research outputs'
  task research_outputs_disable: :environment do
    # Destroy all research outputs which are not defaut research outputs and their answers
    ResearchOutput.where(is_default: false).destroy_all
    Rake::Task['db:migrate:down VERSION=20190503130010'].execute
    Rake::Task['db:migrate:down VERSION=20190620120126'].execute
  end

  desc 'Create Research output types'
  task create_research_output_types: :environment do
    research_output_types = [
      { label: 'Audiovisual' },
      { label: 'Collection' },
      { label: 'Dataset' },
      { label: 'Image' },
      { label: 'Interactive Resource' },
      { label: 'Model' },
      { label: 'Physical Object' },
      { label: 'Service' },
      { label: 'Software' },
      { label: 'Sound' },
      { label: 'Text' },
      { label: 'Workflow' },
      { label: 'Other', is_other: true }
    ]

    research_output_types.map { |s| ResearchOutputType.create!(s) if ResearchOutputType.find_by(label: s[:label]).nil? }
  end

  desc 'Set feedback_requested on existing plans to false'
  task close_existing_feedback_plans: :environment do
    Plan.where(feedback_requested: true).update_all(feedback_requested: false)
  end

  desc 'Add Structured question format in table'
  task add_structure_question_format: :environment do
    if QuestionFormat.find_by(title: 'Structured').nil?
      QuestionFormat.create!({ title: 'Structured', description: 'Structured question format',
                               option_based: false, formattype: 9, structured: true })
    end
  end
end
# rubocop:enable Naming/VariableNumber
