class Annotation < ActiveRecord::Base
  enum type: [:example_answer, :guidance]
  ##
  # Associations
  belongs_to :organisation
  belongs_to :new_question

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :organisation_id, :new_question_id, :text, :type,
                  :organisation, :new_question, :as => [:default, :admin]


  validates :new_question, :organisation,  presence: "need foreign keys"

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
  def self.deep_copy(annotation)
    annotation_copy = annotation.dup
    annotation_copy.save!
    return annotation_copy
  end
end