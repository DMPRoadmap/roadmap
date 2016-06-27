class TokenPermissionType < ActiveRecord::Base

  attr_accessible :token_type, :text_desription, :as => [:default, :admin]

  #associations between tables
  has_many :token_permissions
  has_many :org_token_permissions

  def to_s
    self.token_type
  end

end
