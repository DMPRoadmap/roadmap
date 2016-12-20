class Answer < ActiveRecord::Base
  
  #associations between tables
  belongs_to :question
  belongs_to :user
  belongs_to :plan
  
  has_and_belongs_to_many :options, join_table: "answers_options"
      
  attr_accessible :text, :plan_id, :question_id, :user_id, :option_ids , :as => [:default, :admin]
end
