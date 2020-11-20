# frozen_string_literal: true

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
#  fk_rails_fe95df7db0                (identifier_scheme_id)
#  index_user_identifiers_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (identifier_scheme_id => identifier_schemes.id)
#  fk_rails_...  (user_id => users.id)
#

class UserIdentifier < ApplicationRecord

  # ================
  # = Associations =
  # ================

  belongs_to :user
  belongs_to :identifier_scheme

  # ===============
  # = Validations =
  # ===============

  validates :user, presence: true

  validates :identifier_scheme, presence: { message: PRESENCE_MESSAGE }

  validates :identifier, presence: { message: PRESENCE_MESSAGE }

end
