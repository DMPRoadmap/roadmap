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
    copy = self.dup
    copy.question_id = options.fetch(:question_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:question_option_id] = copy.id
    copy
  end

  private 

  # if we destroy a question_option
  # we need to remove any conditions which depend on it
  # even if they depend on something else as well
  def check_condition_options
    id = self.id.to_s
    self.question.conditions.each do |cond|
      if cond.option_list.include?(id)
        cond.destroy
      end
    end
  end

end
