# frozen_string_literal: true

# Upgrade tasks for 4.x versions. See https://github.com/DMPRoadmap/roadmap/releases for information
# on how and when to run each task.

# rubocop:disable Naming/VariableNumber
namespace :v4 do
  # TODO: In the next release drop column repositories.custom_repository_owner_template_id
  # TODO: In the next release drop columns output_type & output_type_description from research_outputs

  desc 'Upgrade from v4.1.1 to v4.1.2'
  task upgrade_4_1_2: :environment do
    puts 'Migrating custom repository connections (to templates) to new custom_repositories polymorphic table'
    puts 'to support custom repositories being owned by users or templates and to alleviate duplicate repos'

    custom_repos = {}
    duplicates = {}
    # Gather all the custom repos and detect duplicates
    Repository.where.not(custom_repository_owner_template_id: nil).order(created_at: :desc).each do |repo|
      custom_repos[repo.name] = repo if custom_repos[repo.name].nil?
      duplicates[repo.name] = [] if duplicates[repo.name].nil?
      duplicates[repo.name] << repo if custom_repos[repo.name].id != repo.id
    end

    # Delete the duplicate repositories and update any references to them
    duplicates.each do |name, repos|
      next unless repos.any?

      new_repo = custom_repos[name]
      repos.each do |repo|
        refs = ResearchOutput.joins(:repositories).includes(:repositories).where('repositories.id = ?', repo.id)
        puts "Updating references to duplicate '#{name}' - from #{repo.id} to #{new_repo.id}" if refs.any?

        refs.each do |ref|
          puts "  - Updated reference for ResearchOutput #{ref.id}"
          puts "    - related repositories BEFORE: #{ref.repositories.map(&:id)}"
          ref.repositories.delete(repo)
          ref.repositories << new_repo
          puts "    - related repositories AFTER: #{ref.repositories.map(&:id)}"
          ref.save
        end

        puts "Deleting repository #{repo.id}"
        Repository.find_by(id: repo.id).destroy
      end
    end

    # Add the references to the new custom_repositories table and delete the old reference in the repositories table
    custom_repos.each do |name, repo|
      tmplt = Template.joins(:customized_repositories).includes(:customized_repositories)
                      .where('repositories.id = ?', repo.id).first
      next if tmplt.nil?

      puts "Updating refernces to custom repository #{repo.id} for template #{tmplt.id}"
      puts "  - Dropping old reference to custom repo"
      sql = "UPDATE repositories SET custom_repository_owner_template_id = NULL WHERE id = #{repo.id}"
      # Need to do a raw SQL query here because the foreign key field isn't accessible
      ActiveRecord::Base.connection.execute(sql)
      unless tmplt.repositories.include?(repo)
        puts "  - Adding custom repo reference to repositories association"
        tmplt.repositories << repo
      end
      tmplt.save
    end
  end

  desc 'Upgrade from v4.0.x to v4.1.0'
  task upgrade_4_1_0: :environment do
    puts 'Converting the old research_outputs.output_type Integer field (an enum in the model) to a string '
    puts 'value in the new research_outputs.research_output_type field'

    ResearchOutput.all.each do |rec|
      rec.update(research_output_type: rec.output_type_description) if rec.other?
      next if rec.other?

      rec.update(research_output_type: rec.output_type.to_s)
    end

    # Add a generic license type to cover non-standard licenses
    puts "Adding a new 'OTHER' license to allow for scenarios where the user has a custom user agreement"
    License.find_or_create_by(
      name: 'Custom Data Use Agreements/Terms of Use',
      identifier: 'OTHER',
      osi_approved: false,
      deprecated: false
    )

    puts "Converting research outputs whose access level was set to 'embargoed: 1' to 'other: 3' "
    ResearchOutput.where(access: 1).update_all(access: 3)

    puts 'DONE'
  end

  desc 'Upgrade from v4.0.7 to v4.0.8'
  task upgrade_4_0_8: :environment do
    # Seed any existing plans that have requested feedback so that their feedback_start_at date
    # matches the updated_at
    puts 'Seeding new `plans.feedback_start_at` value to `plans.updated_at` date for plans in feedback mode.'
    Plan.where(feedback_requested: true, feedback_start_at: nil).each do |plan|
      plan.update(feedback_start_at: plan.updated_at)
    end
  end
end
# rubocop:enable Naming/VariableNumber
