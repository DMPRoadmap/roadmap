class Perm < ActiveRecord::Base
  ##
  # Associations
  has_and_belongs_to_many :users, :join_table => :users_perms

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :name, :as => [:default, :admin]

  validates :name, presence: true, uniqueness: true

  ##
  # Constant perms
  ADD_ORGS            = Perm.where(name: 'add_organisations').first.freeze
  CHANGE_AFFILIATION  = Perm.where(name: 'change_org_affiliation').first.freeze
  GRANT_PERMISSIONS   = Perm.where(name: 'grant_permissions').first.freeze
  #MODIFY_TEMPLATES    = Perm.where(name: 'modify_templates').first.freeze
  MODIFY_GUIDANCE     = Perm.where(name: 'modify_guidance').first.freeze
  USE_API             = Perm.where(name: 'use_api').first.freeze
  CHANGE_ORG_DETAILS  = Perm.where(name: 'change_org_details').first.freeze
  GRANT_API           = Perm.where(name: 'grant_api_to_orgs').first.freeze
  
  scope :MODIFY_TEMPLATES, -> {Perm.where(name: 'modify_templates').first}
end
