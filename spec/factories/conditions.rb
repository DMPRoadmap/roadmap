# frozen_string_literal: true

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
    option_list { [] }
    remove_data { [] }
    action_type { nil }
    # the webhook_data is a Json string of form:
    # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
    trait :webhook do
      action_type { 'add_webhook' }
      webhook_data do
        #  Generates string from hash
        JSON.generate({
                        name: Faker::Name.name,
                        email: Faker::Internet.email,
                        subject: Faker::Lorem.sentence(word_count: 4),
                        message: Faker::Lorem.paragraph(sentence_count: 2)
                      })
      end
    end
  end
end
