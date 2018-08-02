# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  access     :integer          default(0), not null
#  active     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer
#  user_id    :integer
#
# Indexes
#
#  index_roles_on_plan_id  (plan_id)
#  index_roles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :role do
    user
    plan
    access 1
  end
end
