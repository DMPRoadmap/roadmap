class Language < ActiveRecord::Base
  ##
  # Associations
  has_many :users

  ##
  # Validations
  validates :abbreviation, presence: true, uniqueness: true
end