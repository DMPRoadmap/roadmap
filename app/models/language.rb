class Language < ActiveRecord::Base
  ##
  # Associations
  has_many :users
  has_many :orgs
  
  ##
  # Validations
  validates :abbreviation, presence: true, uniqueness: true
end