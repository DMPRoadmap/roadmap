# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  plan_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  access     :integer          default(0), not null
#  active     :boolean          default(TRUE)
#

FactoryBot.define do
  factory :role do
    user
    plan
    access 1
  end
end
