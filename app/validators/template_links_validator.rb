# frozen_string_literal: true

# Validation for the format of the JSON for Template links
class TemplateLinksValidator < ActiveModel::Validator
  include JsonLinkValidator

  # rubocop:disable Metrics/AbcSize
  def validate(record)
    links = record.links
    expected_keys = %w[funder sample_plan]
    if links.is_a?(Hash)
      expected_keys.each do |k|
        if links.key?(k)
          unless valid_links?(links[k])
            msg = _('The key %{key} does not have a valid set of object links')
            record.errors.add(:links, format(msg, key: k))
          end
        else
          record.errors.add(:links, format(_('A key %{key} is expected for links hash'), key: k))
        end
      end
    else
      record.errors.add(:links, _('A hash is expected for links'))
    end
  end
  # rubocop:enable Metrics/AbcSize
end
