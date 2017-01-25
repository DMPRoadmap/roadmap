class SuggestedAnswer < ActiveRecord::Base

  ##
  # Associations
	belongs_to :org
	belongs_to :question

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
	attr_accessible :org_id, :question_id, :text, :is_example, :as => [:default, :admin]


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

end