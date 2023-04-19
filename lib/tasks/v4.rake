# frozen_string_literal: true

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
