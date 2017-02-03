class SuggestedAnswer < ActiveRecord::Base

  ##
  # Associations
	belongs_to :org
	belongs_to :question

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
	attr_accessible :org_id, :question_id, :text, :is_example, 
                  :org, :question, :as => [:default, :admin]


  validates :question, :org, :text, presence: true

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?



  ##
  # returns the text from the suggested_answer
  #
  # @return [String] the text from the suggested_answer
	def to_s
    "#{text}"
  end


  ##
  # deep copy the given question_option and all it's associations
  #
  # @params [QuestionOption] question_option to be deep copied
  # @return [QuestionOption] the saved, copied question_option
  def self.deep_copy(suggested_answer)
    suggested_answer_copy = suggested_answer.dup
    suggested_answer_copy.save!
    return suggested_answer_copy
  end
end