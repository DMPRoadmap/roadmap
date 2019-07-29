# == Schema Information
#
# Table name: conditions
#
#  id                 :integer          not null, primary key
#  action_type        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  question_option_id :integer
#  remove_question_id :integer
#
# Indexes
#
#  index_conditions_on_question_option_id  (question_option_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_option_id => question_options.id)
#

FactoryBot.define do
  factory :condition do
    question_option { nil }
    remove_question_id { 1 }
  end
end
