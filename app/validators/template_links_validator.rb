class TemplateLinksValidator < ActiveModel::Validator
  include JSONLinkValidator
  def validate(record)
    links = record.links
    expected_keys = ['funder', 'sample_plan']
    if links.is_a?(Hash)
      expected_keys.each do |k|
        if !links.has_key?(k)
          record.errors[:links] << _('A key %{key} is expected for links hash') %{ :key => k }
        else
          record.errors[:links] << _('The key %{key} does not have a valid set of object links') %{ :key => k } unless valid_links?(links[k])
        end
      end
    else
      record.errors[:links] << _('A hash is expected for links')
    end
  end
end