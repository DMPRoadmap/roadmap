class Answer < ActiveRecord::Base
  
  #associations between tables
  belongs_to :question
  belongs_to :user
  belongs_to :plan
  
  has_and_belongs_to_many :options, join_table: "answers_options"
  
# TODO: REMOVE AND HANDLE ATTRIBUTE SECURITY IN THE CONTROLLER!
  attr_accessible :text, :plan_id, :question_id, :user_id, :option_ids, :plan, :user, :question,
                  :as => [:default, :admin]
  
  validates :user, :plan, :question, :text, presence: true
  
  # Make sure there is only one answer per question!
#  validates :question, uniqueness: {scope: [:user, :plan], message: I18n.t('helpers.errors.answer.only_one_per_question')}
end
