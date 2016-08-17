class SuggestedAnswer < ActiveRecord::Base

	belongs_to :organisation
	belongs_to :question

#	accepts_nested_attributes_for :question

	attr_accessible :organisation_id, :question_id, :text, :is_example, :as => [:default, :admin]

  ##
  # returns the text from the suggested_answer
  #
  # @return [String] the text from the suggested_answer
	def to_s
    "#{text}"
  end

end