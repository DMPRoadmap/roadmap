class PlanSection < ActiveRecord::Base
  attr_accessible :plan_id, :release_time, :section_id, :user_id, :as => [:default, :admin]

  #associations between tables
  belongs_to :section
  belongs_to :plan
  belongs_to :user
  
end
