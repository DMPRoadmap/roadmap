# frozen_string_literal: true

# Validation for the format of the JSON for Org links
class OrgLinksValidator < ActiveModel::Validator
  include JsonLinkValidator

  def validate(record)
    links = record.links
    if links.is_a?(Hash)
      unless links.with_indifferent_access.key?('org')
        record.errors.add(:links, _('A key "org" is expected for links hash'))
      end
    else
      record.errors.add(:links, _('A hash is expected for links'))
    end
  end
end
