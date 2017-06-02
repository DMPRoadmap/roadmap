class Answer < ActiveRecord::Base
  
  ##
  # Associations
	belongs_to :question
	belongs_to :user
	belongs_to :plan
  has_many :notes, dependent: :destroy
  has_and_belongs_to_many :question_options, join_table: "answers_question_options"

  has_many :notes

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :text, :plan_id, :lock_version, :question_id, :user_id, :question_option_ids, 
                  :question, :user, :plan, :question_options, :notes, :note_ids, :id,
                  :as => [:default, :admin]

  ##
  # Validations
#  validates :user, :plan, :question, presence: true
#  
#  # Make sure there is only one answer per question!
#  validates :question, uniqueness: {scope: [:plan], 
#                                    message: I18n.t('helpers.answer.only_one_per_question')}
#                                    
#  # The answer MUST have a text value if the question is NOT option based or a question_option if
#  # it is option based. 
#  validates :text, presence: true, if: Proc.new{|a| 
#    (a.question.nil? ? false : !a.question.question_format.option_based?)
#  }
#  validates :question_options, presence: true, if: Proc.new{|a| 
#    (a.question.nil? ? false : a.question.question_format.option_based?)
#  }
#  
#  # Make sure the plan and question are associated with the same template!
#  validates :plan, :question, answer_for_correct_template: true

  # This method helps to decide if an answer option (:radiobuttons, :checkbox, etc ) in form views should be checked or not
  # Returns true if the given option_id is present in question_options, otherwise returns false
  def has_question_option(option_id)
    self.question_option_ids.include?(option_id)
  end

  # Returns true if the answer is valid and false otherwise. If the answer's question is option_based, it is checked if exist
  # any question_option selected. For non option_based (e.g. textarea or textfield), it is checked the presence of text
  def is_valid?
    if self.question.present?
      if self.question.question_format.option_based?
        return !self.question_options.empty?
      else  # (e.g. textarea or textfield question formats)
        return self.text.present?
      end
    else
      return false
    end
  end
end
