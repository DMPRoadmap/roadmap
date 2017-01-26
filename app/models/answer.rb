class Answer < ActiveRecord::Base
  
  ##
  # Associations
	belongs_to :question
	belongs_to :user
	belongs_to :plan
  has_and_belongs_to_many :question_options, join_table: "answers_question_options"

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :text, :plan_id, :question_id, :user_id, :option_ids, 
                  :question, :user, :plan, :as => [:default, :admin]

  ##
  # Validations
  validates :user, :plan, :question, :text, presence: true
  
  # Make sure there is only one answer per question!
  validates :question, uniqueness: {scope: [:user, :plan], 
                                    message: I18n.t('helpers.errors.answer.only_one_per_question')}
end
