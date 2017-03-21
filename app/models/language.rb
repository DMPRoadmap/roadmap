class Language < ActiveRecord::Base
  has_many :users
  
  validates :abbreviation, presence: true, uniqueness: true
end