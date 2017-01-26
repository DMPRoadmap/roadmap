class Perm < ActiveRecord::Base
  ##
  # Associations
  has_and_belongs_to_many :users, :join_table => :users_perms

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :name, :as => [:default, :admin]
end
