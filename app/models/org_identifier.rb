# == Schema Information
#
# Table name: org_identifiers
#
#  id                   :integer          not null, primary key
#  identifier           :string
#  attrs                :string
#  created_at           :datetime
#  updated_at           :datetime
#  org_id               :integer
#  identifier_scheme_id :integer
#
# Indexes
#
#  org_identifiers_identifier_scheme_id_idx  (identifier_scheme_id)
#  org_identifiers_org_id_idx                (org_id)
#

class OrgIdentifier < ActiveRecord::Base
  include ValidationMessages

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

  # ===========================
  # = Public instance methods =
  # ===========================

  def attrs=(hash)
    write_attribute(:attrs, (hash.is_a?(Hash) ? hash.to_json.to_s : '{}'))
  end
end
