class UserOrgRole < ActiveRecord::Base
  attr_accessible :organisation_id, :user_id, :user_role_type_id, :as => [:default, :admin]

  #associations between tables
  belongs_to :user
  belongs_to :organisation
  belongs_to :user_role_type
    
end
