# == Schema Information
#
# Table name: notes
#
#  id          :integer          not null, primary key
#  archived    :boolean
#  archived_by :integer
#  text        :text
#  created_at  :datetime
#  updated_at  :datetime
#  answer_id   :integer
#  user_id     :integer
#
# Indexes
#
#  index_notes_on_answer_id  (answer_id)
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :note do
    user
    text { Faker::Lorem.sentence }
    answer
    archived false
  end
end
