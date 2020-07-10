# frozen_string_literal: true

class TemplateLinksValidator < ActiveModel::Validator

  include JSONLinkValidator
  def validate(record)
    links = record.links
    expected_keys = %w[funder sample_plan]
    if links.is_a?(Hash)
      expected_keys.each do |k|
        if !links.key?(k)
          record.errors[:links] << _("A key %{key} is expected for links hash") % { key: k }
        else
          unless valid_links?(links[k])
            msg = _("The key %{key} does not have a valid set of object links")
            record.errors[:links] << msg % { key: k }
          end
        end
      end
    else
      record.errors[:links] << _("A hash is expected for links")
    end
  end

end
