# frozen_string_literal: true

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

class QuestionOption < ApplicationRecord

  include VersionableModel

  # ================
  # = Associations =
  # ================

  belongs_to :question

  has_one :section, through: :question

  has_one :phase, through: :question

  has_one :template, through: :question

  has_and_belongs_to_many :answers, join_table: :answers_question_options

  # ===============
  # = Validations =
  # ===============

  validates :text, presence: { message: PRESENCE_MESSAGE }

  validates :question, presence: { message: PRESENCE_MESSAGE }

  validates :number, presence: { message: PRESENCE_MESSAGE }

  validates :is_default, inclusion: { in: BOOLEAN_VALUES,
                                      message: INCLUSION_MESSAGE }

  # =============
  # = Callbacks =
  # =============

  # TODO: condition.option_list needs to be serialized (from Array) before we can check
  # for related conditions, so this can't be replaced by :destroy on the association
  before_destroy :check_condition_options

  # ==========
  # = Scopes =
  # ==========

  scope :by_number, -> { order(:number) }

  # ===========================
  # = Public instance methods =
  # ===========================

  # ===========================
  # = Public instance methods =
  # ===========================

  def deep_copy(**options)
    copy = dup
    copy.question_id = options.fetch(:question_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:question_option_id] = copy.id
    copy
  end

  private

  # if we destroy a question_option
  # we need to remove any conditions which depend on it
  # even if they depend on something else as well
  # doesn't look like there's a way for destroy to fail though, so no need to
  # add callback halting with abort
  def check_condition_options
    id = self.id.to_s
    question.conditions.each do |cond|
      cond.destroy if cond.option_list.include?(id)
    end
  end

end
