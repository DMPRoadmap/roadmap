class QuestionFormat < ActiveRecord::Base
  attr_accessible :title, :description, :as => [:default, :admin]
  
  #associations between tables
  has_many :questions
  
   def to_s
    "#{title}"
  end
  
  
end