require 'set'
namespace :dmpopidor_upgrade do

  desc "Upgrade to 2.1.0"
  task v2_1_0: :environment do
    Rake::Task['dmpopidor_upgrade:add_themes_token_permission_types'].execute
    Rake::Task['dmpopidor_upgrade:grant_themes_api_to_all_orgs'].execute
    Rake::Task['dmpopidor_upgrade:grant_api_to_all_orgs'].execute
    Rake::Task['dmpopidor_upgrade:create_number_field'].execute
  end
  
  desc "Upgrade to 2.2.0"
  task v2_2_0: :environment do
    Rake::Task['dmpopidor_upgrade:datasets_enable'].execute
  end


  desc "Add the themes token permission type"
  task add_themes_token_permission_types: :environment do
    if TokenPermissionType.find_by(token_type: 'themes').nil?
      TokenPermissionType.create!({token_type: 'themes',
                                   text_description: 'allows a user access to the themes api endpoint'})
    end
  end

  desc "Grant themes API to all orgs"
  task grant_themes_api_to_all_orgs: :environment do
    orgs = Org.where(is_other: false).select(:id) + Org.where(is_other: nil).select(:id)
    orgs.each do |org|
        org.grant_api!(TokenPermissionType.where(token_type: 'themes'))
      end
  end

  desc "Grant all API to all orgs"
  task grant_api_to_all_orgs: :environment do
    orgs = Org.where(is_other: false).select(:id) + Org.where(is_other: nil).select(:id)
    orgs.each do |org|
        org.grant_api!(TokenPermissionType.where(token_type: 'guidances'))
        org.grant_api!(TokenPermissionType.where(token_type: 'plans'))
        org.grant_api!(TokenPermissionType.where(token_type: 'templates'))
        org.grant_api!(TokenPermissionType.where(token_type: 'statistics'))
      end
  end

  desc "Create number field"
  task create_number_field: :environment do
    if QuestionFormat.find_by(title: 'Number').nil?
        QuestionFormat.create!({title: 'Number', option_based: false, formattype: 8})
    end
  end


  # Migrates the database to use datasets
  # - Adds a dataset table to the base (via the above migrations)
  # - Creates a default dataset for every plan
  # - Moves all plans' answers to their new default dataset
  desc 'Migrate the database to use datasets'
  task datasets_enable: :environment do
    # Apply migration
    # DatasetsMigration.new.up

    # Create datasets and move answers
    Plan.all.each do |p|
      dataset = p.datasets.create(is_default: true, order: 1) if p.datasets.empty?

      p.answers.each { |a| a.update_column(:dataset_id, dataset.id) }
    end
  end

  # Rollback for the database migration enable the datasets
  # - Remove all non default datasets and their answers
  # - "Detach" remaining answers from their datasets (the default ones)
  # - Drop the datasets table and reverse the migrations
  desc 'Migrate the database to remove datasets'
  task datasets_disable: :environment do
    # Destroy all datasets which are not defaut datasets and their answers
    Dataset.where(is_default: false).destroy_all

    # Rollback migration
    # DatasetsMigration.new.down
    Rake::Task['db:migrate:down VERSION=20190503130010'].execute
  end

end
