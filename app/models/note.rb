class Note < ActiveRecord::Base
  ##
  # Associations
  belongs_to :answer
  belongs_to :user

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :question_id, :text, :user_id, :archived, :plan_id, :archived_by, :as => [:default, :admin]
end
