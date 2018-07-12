# == Schema Information
#
# Table name: exported_plans
#
#  id         :integer          not null, primary key
#  plan_id    :integer
#  user_id    :integer
#  format     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  phase_id   :integer
#

FactoryBot.define do
  factory :exported_plan do
    user
    plan
    phase_id { create(:phase).id }
    format { ExportedPlan::VALID_FORMATS.sample }
  end
end
