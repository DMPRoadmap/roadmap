# == Schema Information
#
# Table name: token_permission_types
#
#  id               :integer          not null, primary key
#  text_description :text
#  token_type       :string
#  created_at       :datetime
#  updated_at       :datetime
#

class TokenPermissionType < ActiveRecord::Base
  include ValidationMessages

  # =============
  # = Constants =
  # =============

  ##
  #
  GUIDANCES   = TokenPermissionType.where(token_type: 'guidances').first.freeze

  ##
  #
  PLANS       = TokenPermissionType.where(token_type: 'plans').first.freeze

  ##
  #
  TEMPLATES   = TokenPermissionType.where(token_type: 'templates').first.freeze

  ##
  #
  STATISTICS  = TokenPermissionType.where(token_type: 'statistics').first.freeze


  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :orgs, join_table: 'org_token_permissions', unique: true


  # ==============
  # = Validators =
  # ==============

  validates :token_type, presence: { message: PRESENCE_MESSAGE },
                         uniqueness: { message: UNIQUENESS_MESSAGE }


  ##
  # returns the token_type of the token_permission_type
  #
  # @return [String] token_type of the token_permission_type
  def to_s
    self.token_type
  end

end
