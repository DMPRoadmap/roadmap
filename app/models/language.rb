class Language < ActiveRecord::Base
  has_many :users
  has_many :organisations
  
  validates :abbreviation, presence: true, uniqueness: true
end