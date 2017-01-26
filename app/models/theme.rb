class Theme < ActiveRecord::Base

  ##
  # Associations
  has_and_belongs_to_many :questions, join_table: "questions_themes"
  has_and_belongs_to_many :guidances, join_table: "themes_in_guidance"

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :guidance_ids , :as => [:default, :admin]
  attr_accessible :question_ids, :as => [:default, :admin]
  attr_accessible :description, :title, :locale , :as => [:default, :admin]


  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?



  ##
  # returns the title of the theme
  #
  # @return [String] title of the theme
  def to_s
  	title
  end

end
