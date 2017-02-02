class Answer < ActiveRecord::Base
  ##
  # Associations
	belongs_to :question
	belongs_to :user
	belongs_to :plan
  has_many :notes, dependent: :destroy
  has_and_belongs_to_many :question_options, join_table: "answers_question_options"

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :text, :plan_id, :question_id, :user_id, :option_ids , :as => [:default, :admin]
end
