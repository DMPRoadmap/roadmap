# == Schema Information
#
# Table name: conditions
#
#  id                 :integer          not null, primary key
#  question_id        :integer
#  number             :integer
#  action_type        :integer
#  option_list        :text
#  remove_data        :text
#  webhook_data       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_conditions_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => question.id)
#
# 

FactoryBot.define do
  factory :condition do
    option_list { nil }
    remove_data { nil }
  end
end
