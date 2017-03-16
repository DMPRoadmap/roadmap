class Language < ActiveRecord::Base
  ##
  # Associations
  has_many :users
  has_many :orgs
  
  ##
  # Validations
  validates :abbreviation, presence: true, uniqueness: true

  scope :sorted_by_abbreviation, -> { all.order(:abbreviation) }
  scope :default, -> { where(default_language: true).first }
end