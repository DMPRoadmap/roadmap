# frozen_string_literal: true

# == Schema Information
#
# Table name: conditions
#
#  id           :integer          not null, primary key
#  action_type  :integer
#  number       :integer
#  option_list  :text(65535)
#  remove_data  :text(65535)
#  webhook_data :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  question_id  :integer
#
# Indexes
#
#  index_conditions_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#

FactoryBot.define do
  factory :condition do
    option_list { nil }
    remove_data { nil }
  end
end
