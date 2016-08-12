class ProjectPartner < ActiveRecord::Base
  attr_accessible :leader_org, :organisation_id, :project_id, :as => [:default, :admin]
end
