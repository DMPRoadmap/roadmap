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

class Note < ApplicationRecord

  # ================
  # = Associations =
  # ================

  belongs_to :answer

  belongs_to :user

  # ===============
  # = Validations =
  # ===============

  validates :text, presence: { message: PRESENCE_MESSAGE }

  validates :answer, presence: { message: PRESENCE_MESSAGE }

  validates :user, presence: { message: PRESENCE_MESSAGE }

  validates :archived, inclusion: { in: BOOLEAN_VALUES,
                                    message: INCLUSION_MESSAGE }

end
