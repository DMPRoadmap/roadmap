# frozen_string_literal: true

# == Schema Information
#
# Table name: org_identifiers
#
#  id                   :integer          not null, primary key
#  attrs                :string
#  identifier           :string
#  created_at           :datetime
#  updated_at           :datetime
#  identifier_scheme_id :integer
#  org_id               :integer
#
# Indexes
#
#  fk_rails_189ad2e573  (identifier_scheme_id)
#  fk_rails_36323c0674  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (identifier_scheme_id => identifier_schemes.id)
#  fk_rails_...  (org_id => orgs.id)
#

class OrgIdentifier < ApplicationRecord

  # ================
  # = Associations =
  # ================

  belongs_to :org
  belongs_to :identifier_scheme

  # ===============
  # = Validations =
  # ===============

  # Should only be able to have one identifier per scheme!
  validates :identifier_scheme_id, uniqueness: { scope: :org_id,
                                                 message: UNIQUENESS_MESSAGE }

  validates :identifier, presence: { message: PRESENCE_MESSAGE }

  validates :org, presence: { message: PRESENCE_MESSAGE }

  validates :identifier_scheme, presence: { message: PRESENCE_MESSAGE }

  # =========================
  # = Custom Accessor Logic =
  # =========================

  # ensure attrs is a hash before saving
  # TODO: evaluate this approach vs Serialize from condition.rb
  def attrs=(hash)
    super(hash.is_a?(Hash) ? hash.to_json.to_s : "{}")
  end

end
