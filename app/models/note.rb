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

class Note < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues

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
