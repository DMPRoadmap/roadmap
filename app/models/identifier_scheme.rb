# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string
#  logo_url         :text
#  name             :string
#  user_landing_url :text
#  created_at       :datetime
#  updated_at       :datetime
#  context          :integer
#

class IdentifierScheme < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues

  ##
  # The maximum length for a name
  NAME_MAXIMUM_LENGTH = 30

  has_many :user_identifiers
  has_many :users, through: :user_identifiers

  # ===============
  # = Attributes =
  # ===============
  enum context: %i[org user]

  # ===============
  # = Validations =
  # ===============
  validates :name, uniqueness: { message: UNIQUENESS_MESSAGE },
                   presence: { message: PRESENCE_MESSAGE },
                   length: { maximum: NAME_MAXIMUM_LENGTH }

  validates :active, inclusion: { message: INCLUSION_MESSAGE,
                                  in: BOOLEAN_VALUES }
  validates :context, inclusion: { message: INCLUSION_MESSAGE, in: contexts },
                      presence: { message: PRESENCE_MESSAGE }

  # ===========================
  # = Scopes =
  # ===========================
  scope :user_schemes, -> { where(context: contexts[:user]) }
  scope :org_schemes, -> { where(context: contexts[:org]) }

  scope :by_name, ->(value) { where("LOWER(name) = LOWER(?)", value) }

end
