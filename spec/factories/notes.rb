# == Schema Information
#
# Table name: notes
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  text        :text
#  archived    :boolean          default("false"), not null
#  answer_id   :integer
#  archived_by :integer
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  notes_answer_id_idx  (answer_id)
#  notes_user_id_idx    (user_id)
#

FactoryBot.define do
  factory :note do
    user
    text { Faker::Lorem.sentence }
    answer
    archived { false }
  end
end
