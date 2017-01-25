class NewSuggestedAnswer < ActiveRecord::Base
  belongs_to :new_question
  belongs_to :organisation
end
