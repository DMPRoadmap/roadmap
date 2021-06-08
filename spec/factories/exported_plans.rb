# frozen_string_literal: true

# == Schema Information
#
# Table name: exported_plans
#
#  id         :integer          not null, primary key
#  format     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  phase_id   :integer
#  plan_id    :integer
#  user_id    :integer
#

FactoryBot.define do
  factory :exported_plan do
    format { %w[csv txt docx pdf xml].sample }
  end
end
