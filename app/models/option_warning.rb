class OptionWarning < ActiveRecord::Base
  
	#associations between tables
	belongs_to :option
	belongs_to :organisation
	
    attr_accessible :text, :option_id, :organisation_id, :as => [:default, :admin]
  
	def to_s
		"#{text}"
	end
end