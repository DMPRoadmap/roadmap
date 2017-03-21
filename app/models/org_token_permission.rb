class OrgTokenPermission < ActiveRecord::Base
  attr_accessible :organisation_id, :token_permission_type_id, :organisation, :token_permission_type, :as => [:default, :admin]

  #associations between tables
  belongs_to :organisation
  belongs_to :token_permission_type

end
