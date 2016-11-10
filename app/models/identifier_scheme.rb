class IdentifierScheme < ActiveRecord::Base
  has_many :user_identifiers
  has_many :users, through: :user_identifiers
  
  validates :name, uniqueness: true, presence: true
end