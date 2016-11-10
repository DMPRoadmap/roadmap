class IdentifierScheme < ActiveRecord::Base
  has_many :user_identifiers
  has_many :users, through: :user_identifiers
  
  validates :name, uniqueness: true, presence: true
  validates :landing_page_uri, url: true, allow_nil: true
end