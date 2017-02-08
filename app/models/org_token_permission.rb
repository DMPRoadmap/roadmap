=begin
class OrgTokenPermission < ActiveRecord::Base
  ##
  # Associations
  belongs_to :organisation
  belongs_to :token_permission_type

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :organisation_id, :token_permission_type_id, :organisation, :token_permission_type, :as => [:default, :admin]
end
=end