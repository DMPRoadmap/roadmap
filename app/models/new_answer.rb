class NewAnswer < ActiveRecord::Base
  belongs_to :new_plan
  belongs_to :new_question
  has_many :question_options, through: :new_answers_question_options
  has_many :notes
  belongs_to :user
end
