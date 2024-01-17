# frozen_string_literal: true

# Helper methods for displaying Identifiers
module IdentifierHelper
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def id_for_display(id:, with_scheme_name: true)
    return _('None defined') if id.new_record? || id.value.blank?
    # Sandbox DOIs do not resolve so swap in the direct URL to the Minting service
    return sandbox_dmp_id(id: id) if !Rails.env.production? &&
                                     id.identifier_scheme == DmpIdService.identifier_scheme

    without = id.value_without_scheme_prefix
    prefix = with_scheme_name ? "#{id.identifier_scheme.description}: " : ''
    return prefix + id.value unless without != id.value && !without.starts_with?('http')

    link_to without, id.value, class: 'has-new-window-popup-info'
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  def sandbox_dmp_id(id:, with_domain: false)
    return _('None defined') if id.blank?

    url = DmpIdService.landing_page_url
    without = id.gsub(/^https?:\/\/doi.org\//, '')

    return id unless url.present? && without != id && !without.starts_with?('http')

    link_to(with_domain ? id : without, "#{url}#{without}", class: 'has-new-window-popup-info')
  end
end
