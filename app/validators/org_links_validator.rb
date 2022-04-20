# frozen_string_literal: true

<<<<<<< HEAD
class OrgLinksValidator < ActiveModel::Validator

=======
# Validation for the format of the JSON for Org links
class OrgLinksValidator < ActiveModel::Validator
>>>>>>> upstream/master
  include JSONLinkValidator
  def validate(record)
    links = record.links
    if links.is_a?(Hash)
<<<<<<< HEAD
      unless links.with_indifferent_access.key?("org")
        record.errors[:links] << _('A key "org" is expected for links hash') % { key: k }
      end
    else
      record.errors[:links] << _("A hash is expected for links")
    end
  end

=======
      unless links.with_indifferent_access.key?('org')
        record.errors[:links] << (format(_('A key "org" is expected for links hash'), key: k))
      end
    else
      record.errors[:links] << _('A hash is expected for links')
    end
  end
>>>>>>> upstream/master
end
