# frozen_string_literal: true

# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string
#  context          :integer
#  logo_url         :text
#  name             :string
#  user_landing_url :string
#  created_at       :datetime
#  updated_at       :datetime
#

# Object that represents a type of identifiaction (e.g. ORCID, ROR, etc.)
class IdentifierScheme < ApplicationRecord
  include FlagShihTzu

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
  scope :by_name, ->(value) { active.where('LOWER(name) = LOWER(?)', value) }

  ##
  # Define Bit Field values for the scheme's context
  # These are used to determine when and where an identifier scheme is applicable
  has_flags 1 => :for_authentication,
            2 => :for_orgs,
            3 => :for_plans,
            4 => :for_users,
            5 => :for_contributors,
            column: 'context',
            check_for_column: !Rails.env.test?

  # =========================
  # = Custom Accessor Logic =
  # =========================

  # The name is used by the OrgSelection Services as a Hash key. For example:
  #    { "ror": "12345" }
  # so we cannot allow spaces or non alpha characters!
  def name=(value)
    super(value&.downcase&.gsub(/[^a-z]/, ''))
  end

  # ===========================
  # = Instance Methods =
  # ===========================
end
