class NewSection < ActiveRecord::Base
  belongs_to :new_phase
  has_many :new_questions
end
