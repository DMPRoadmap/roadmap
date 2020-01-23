# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string
#  for_auth         :boolean          default(FALSE)
#  for_orgs         :boolean          default(FALSE)
#  for_plans        :boolean          default(FALSE)
#  for_users        :boolean          default(FALSE)
#  logo_url         :text
#  name             :string
#  user_landing_url :string
#  created_at       :datetime
#  updated_at       :datetime
#

class IdentifierScheme < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues

  ##
  # The maximum length for a name
  NAME_MAXIMUM_LENGTH = 30

  has_many :identifiers

  # ===============
  # = Validations =
  # ===============

  validates :name, uniqueness: { message: UNIQUENESS_MESSAGE },
                   presence: { message: PRESENCE_MESSAGE },
                   length: { maximum: NAME_MAXIMUM_LENGTH }

  validates :active, inclusion: { message: INCLUSION_MESSAGE,
                                  in: BOOLEAN_VALUES }

  # ===========================
  # = Scopes =
  # ===========================

  scope :active, -> { where(active: true) }
  scope :for_users, -> { active.where(for_users: true) }
  scope :for_orgs, -> { active.where(for_orgs: true) }
  scope :for_plans, -> { active.where(for_plans: true) }
  scope :authenticatable, -> { active.where(for_auth: true) }
  scope :by_name, ->(value) { active.where("LOWER(name) = LOWER(?)", value) }

  # ===========================
  # = Instance Methods =
  # ===========================

  # The name is used by the OrgSelection Services as a Has key. For example:
  #    { "ror": "12345" }
  # so we cannot allow spaces or non alpha characters!
  def name=(value)
    super(value&.downcase&.gsub(/[^a-z]/, ""))
  end

end
