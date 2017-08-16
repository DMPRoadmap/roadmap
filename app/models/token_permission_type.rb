class TokenPermissionType < ActiveRecord::Base
  ##
  # Associations
  #has_and_belongs_to_many :org_token_permissions, join_table: "org_token_permissions"
#  has_and_belongs_to_many :organisations, join_table: 'org_token_permissions', unique: true
  has_and_belongs_to_many :orgs, join_table: 'org_token_permissions', unique: true

  ##
  # Possibly needed for active_admin
  #  - relies on proetected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :token_type, :text_description, :as => [:default, :admin]

  ##
  # Validators
  validates :token_type, presence: {message: _("can't be blank")}, uniqueness: {message: _("must be unique")}

  ##
  # Constant Token Permission Types
  GUIDANCES   = TokenPermissionType.where(token_type: 'guidances').first.freeze
  PLANS       = TokenPermissionType.where(token_type: 'plans').first.freeze
  TEMPLATES   = TokenPermissionType.where(token_type: 'templates').first.freeze
  STATISTICS  = TokenPermissionType.where(token_type: 'statistics').first.freeze


  ##
  # returns the token_type of the token_permission_type
  #
  # @return [String] token_type of the token_permission_type
  def to_s
    self.token_type
  end

end
