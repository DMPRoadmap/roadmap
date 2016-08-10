class Option < ActiveRecord::Base
  
	#associations between tables
	belongs_to :question
    
  has_many :option_warnings, :dependent => :destroy
	
  has_and_belongs_to_many :answers, join_table: "answers_options"
    
	attr_accessible :text, :question_id, :is_default, :number, :as => [:default, :admin]
  
	def to_s
		"#{text}"
	end
end