class TokenPermissionType < ActiveRecord::Base

  attr_accessible :token_type, :text_desription, :as => [:default, :admin]

  #associations between tables
  has_and_belongs_to_many :org_token_permissions, join_table: "org_token_permissions"

  ##
  # returns the token_type of the token_permission_type
  #
  # @return [String] token_type of the token_permission_type
  def to_s
    self.token_type
  end

end
