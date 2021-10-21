# frozen_string_literal: true

module IdentifierHelper

  def create_orcid(user:, val: SecureRandom.uuid)
    scheme = orcid_scheme
    val = append_prefix(scheme: scheme, val: val)
    create(:identifier, identifiable: user, identifier_scheme: scheme, value: val)
  end

  def orcid_scheme
    name = Rails.configuration.x.orcid.name || "orcid"
    landing_page = Rails.configuration.x.orcid.landing_page_url || "https://orcid.org/"
    scheme = IdentifierScheme.find_by(name: name)
    scheme.update(identifier_prefix: landing_page) if scheme.present?
    return scheme if scheme.present?

    create(:identifier_scheme, :for_identification, :for_users, name: name,
                                                                identifier_prefix: landing_page)
  end

  def append_prefix(scheme:, val:)
    val = val.start_with?("/") ? val[1..val.length] : val
    url = landing_page_for(scheme: scheme)
    val.start_with?(url) ? val : "#{url}#{val}"
  end

  def remove_prefix(scheme:, val:)
    val.gsub(landing_page_for(scheme: scheme), "")
  end

  def landing_page_for(scheme:)
    url = scheme.identifier_prefix
    unless url.present?
      url = Rails.configuration.x.send(:"#{scheme.name.downcase}")&.landing_page_url
    end
    return nil unless url.present?

    %w[/ : & ?].include?(url.last) ? url : "#{url}/"
  end

end
