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
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :user
  belongs_to :identifier_scheme

  # ===============
  # = Validations =
  # ===============

  validates :user, presence: true

  validates :identifier_scheme, presence: true

  validates :identifier_scheme_id, uniqueness: { scope: :user_id,
                                                 message: UNIQUENESS_MESSAGE }

  validates :identifier, presence: { message: PRESENCE_MESSAGE }
end
