class IdentifierScheme < ActiveRecord::Base
  has_many :user_identifiers
  has_many :users, through: :user_identifiers
  
  validates :name, uniqueness: {message: _("must be unique")}, presence: {message: _("can't be blank")}
end