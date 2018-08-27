# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string(255)
#  logo_url         :string(255)
#  name             :string(255)
#  user_landing_url :string(255)
#  created_at       :datetime
#  updated_at       :datetime
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
  # = Validations =
  # ===============

  validates :name, uniqueness: { message: UNIQUENESS_MESSAGE },
                   presence: { message: PRESENCE_MESSAGE },
                   length: { maximum: NAME_MAXIMUM_LENGTH }

  validates :active, inclusion: { message: INCLUSION_MESSAGE,
                                  in: BOOLEAN_VALUES }

end
