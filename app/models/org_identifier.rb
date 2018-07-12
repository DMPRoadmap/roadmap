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
# Foreign Keys
#
#  fk_rails_...  (identifier_scheme_id => identifier_schemes.id)
#  fk_rails_...  (org_id => orgs.id)
#

class OrgIdentifier < ActiveRecord::Base
  belongs_to :org
  belongs_to :identifier_scheme
  
  # Should only be able to have one identifier per scheme!
  validates_uniqueness_of :identifier_scheme, scope: :org
  
  validates :identifier, :org, :identifier_scheme, presence: {message: _("can't be blank")}
  
  def attrs=(hash)
    write_attribute(:attrs, (hash.is_a?(Hash) ? hash.to_json.to_s : '{}'))
  end
end
