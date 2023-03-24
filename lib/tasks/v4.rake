# frozen_string_literal: true

# Upgrade tasks for 4.x versions. See https://github.com/DMPRoadmap/roadmap/releases for information
# on how and when to run each task.

# rubocop:disable Naming/VariableNumber
namespace :v4 do
  desc 'Upgrade from v4.0.x to v4.1.0'
  task upgrade_4_1_0: :environment do
    puts 'Converting the old research_outputs.output_type Integer field (an enum in the model) to a string '
    puts 'value in the new research_outputs.research_output_type field'

    ResearchOutput.all.each do |rec|
      rec.update(research_output_type: rec.output_type_description) if rec.other?
      next if rec.other?

      rec.update(research_output_type: rec.output_type.to_s)
    end

    puts 'DONE'

# Upgrade tasks for 34.x versions.

# rubocop:disable Naming/VariableNumber
namespace :v4 do
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
