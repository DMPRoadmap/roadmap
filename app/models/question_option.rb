class QuestionOption < ActiveRecord::Base
  ##
  # Associations
  belongs_to :question
  has_and_belongs_to_many :answers, join_table: :answers_question_options

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :text, :question_id, :is_default, :number, :as => [:default, :admin]
end
