class UserIdentifier < ActiveRecord::Base
  belongs_to :user
  belongs_to :identifier_scheme
  
  # Should only be able to have one identifier per scheme!
  validates_uniqueness_of :identifier_scheme, scope: :user
  
  validates :identifier, :user, :identifier_scheme, presence: {message: _("can't be blank")}
end