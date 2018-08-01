# == Schema Information
#
# Table name: question_options
#
#  id          :integer          not null, primary key
#  is_default  :boolean
#  number      :integer
#  text        :string
#  created_at  :datetime
#  updated_at  :datetime
#  question_id :integer
#
# Indexes
#
#  index_question_options_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#

class QuestionOption < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues

  # ================
  # = Associations =
  # ================

  belongs_to :question

  has_and_belongs_to_many :answers, join_table: :answers_question_options


  # ===============
  # = Validations =
  # ===============

  validates :text, presence: { message: PRESENCE_MESSAGE }

  validates :question, presence: { message: PRESENCE_MESSAGE }

  validates :number, presence: { message: PRESENCE_MESSAGE }

  validates :is_default, inclusion: { in: BOOLEAN_VALUES,
                                      message: INCLUSION_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :by_number, -> { order(:number) }

  # =================
  # = Class methods =
  # =================

  ##
  # deep copy the given question_option and all it's associations
  #
  # @params [QuestionOption] question_option to be deep copied
  # @return [QuestionOption] the saved, copied question_option
  def self.deep_copy(question_option)
    question_option_copy = question_option.dup
    question_option_copy.save!
    return question_option_copy
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  def deep_copy(**options)
    copy = self.dup
    copy.question_id = options.fetch(:question_id, nil)
    return copy
  end
end
