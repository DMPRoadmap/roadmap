class UserRoleType < ActiveRecord::Base
  
  #associations between tables
  has_many :user_org_roles
  
  attr_accessible :description, :name, :as => [:default, :admin]
end
