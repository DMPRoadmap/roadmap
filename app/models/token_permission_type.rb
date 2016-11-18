class TokenPermissionType < ActiveRecord::Base

  attr_accessible :token_type, :text_description, :as => [:default, :admin]

  #associations between tables
  #has_and_belongs_to_many :org_token_permissions, join_table: "org_token_permissions"
  has_and_belongs_to_many :organisations, join_table: 'org_token_permissions'

  validates :token_type, presence: true, uniqueness: true

  ##
  # returns the token_type of the token_permission_type
  #
  # @return [String] token_type of the token_permission_type
  def to_s
    self.token_type
  end

end
