# frozen_string_literal: true

class OrgLinksValidator < ActiveModel::Validator

  include JSONLinkValidator
  def validate(record)
    links = record.links
    if links.is_a?(Hash)
      unless links.with_indifferent_access.key?("org")
        record.errors[:links] << _('A key "org" is expected for links hash') % { key: k }
      end
    else
      record.errors[:links] << _("A hash is expected for links")
    end
  end

end
