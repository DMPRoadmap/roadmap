# frozen_string_literal: true

# == Schema Information
#
# Table name: notes
#
#  id          :integer          not null, primary key
#  archived    :boolean          default(FALSE), not null
#  archived_by :integer
#  text        :text
#  created_at  :datetime
#  updated_at  :datetime
#  answer_id   :integer
#  user_id     :integer
#
# Indexes
#
#  fk_rails_7f2323ad43       (user_id)
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
    archived { false }
  end
end
