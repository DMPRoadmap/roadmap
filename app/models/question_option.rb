class QuestionOption < ActiveRecord::Base
  ##
  # Associations
  belongs_to :question
  has_and_belongs_to_many :answers, join_table: :answers_question_options

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :text, :question_id, :is_default, :number, :question, 
                  :as => [:default, :admin]

  validates :text, :question, :number, presence: {message: _("can't be blank")}

  scope :by_number, -> { order(:number) }
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

  def deep_copy(**options)
    copy = self.dup
    copy.question_id = options.fetch(:question_id, nil)
    return copy
  end
end
