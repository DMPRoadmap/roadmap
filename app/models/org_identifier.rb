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