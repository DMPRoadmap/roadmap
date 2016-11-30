class QuestionOption < ActiveRecord::Base
  belongs_to :question
  has_and_belongs_to_many :new_answers, join_table: :new_answers_question_options
end
