# == Schema Information
#
# Table name: user_identifiers
#
#  id                   :integer          not null, primary key
#  identifier           :string
#  created_at           :datetime
#  updated_at           :datetime
#  identifier_scheme_id :integer
#  user_id              :integer
#
# Indexes
#
#  index_user_identifiers_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (identifier_scheme_id => identifier_schemes.id)
#  fk_rails_...  (user_id => users.id)
#

class UserIdentifier < ActiveRecord::Base
  belongs_to :user
  belongs_to :identifier_scheme
  
  # Should only be able to have one identifier per scheme!
  validates_uniqueness_of :identifier_scheme, scope: :user
  
  validates :identifier, :user, :identifier_scheme, presence: {message: _("can't be blank")}
end
