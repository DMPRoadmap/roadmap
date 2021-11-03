# frozen_string_literal: true

module IdentifierHelper

  def create_orcid(user:, val: random_orcid)
    scheme = orcid_scheme
    val = append_prefix(scheme: scheme, val: val)
    create(:identifier, identifiable: user, identifier_scheme: scheme, value: val)
  end

  def create_dmp_id(plan:, val: random_doi)
    scheme = dmp_id_scheme
    val = append_prefix(scheme: scheme, val: val)
    create(:identifier, identifiable: plan, identifier_scheme: scheme, value: val)
  end

  def orcid_scheme
    name = Rails.configuration.x.orcid.name || 'orcid'
    landing_page = Rails.configuration.x.orcid.landing_page_url || 'https://orcid.org/'
    scheme = IdentifierScheme.find_by(name: name)
    scheme.update(identifier_prefix: landing_page) if scheme.present?
    return scheme if scheme.present?

    create(:identifier_scheme, for_users: true, name: name, identifier_prefix: landing_page)
  end

  def dmp_id_scheme
    name = DmpIdService.identifier_scheme&.name || "datacite"
    landing_page = DmpIdService.landing_page_url || "https://doi.org/"
    scheme = IdentifierScheme.find_by(name: name)
    scheme.update(identifier_prefix: landing_page) if scheme.present?
    return scheme if scheme.present?

    create(:identifier_scheme, for_plans: true, name: name, identifier_prefix: landing_page)
  end

  def random_orcid
    id = [
      Faker::Number.number(digits: 4),
      Faker::Number.number(digits: 4),
      Faker::Number.number(digits: 4),
      Faker::Number.number(digits: 4)
    ]
    id.join("-")
  end

  def random_doi
    shoulder = [
      Faker::Number.number(digits: 2),
      Faker::Number.number(digits: 4)
    ]
    id = [
      Faker::Alphanumeric.alphanumeric(number: 5),
      Faker::Alphanumeric.alphanumeric(number: 4)
    ]
    [shoulder.join("."), id.join(".")].join("/")
  end

  def doi_scheme
    name = DoiService.scheme_name || "datacite"
    landing_page = DoiService.landing_page_url || "https://doi.org/"
    scheme = IdentifierScheme.find_by(name: name)
    scheme.update(identifier_prefix: landing_page) if scheme.present?
    return scheme if scheme.present?

    create(:identifier_scheme, :for_identification, :for_users, name: name,
                                                                identifier_prefix: landing_page)
  end

  def append_prefix(scheme:, val:)
    val = val.start_with?('/') ? val[1..val.length] : val
    url = landing_page_for(scheme: scheme)
    val.start_with?(url) ? val : "#{url}#{val}"
  end

  def remove_prefix(scheme:, val:)
    val.gsub(landing_page_for(scheme: scheme), '')
  end

  def landing_page_for(scheme:)
    url = scheme.identifier_prefix
    url = Rails.configuration.x.send(:"#{scheme.name.downcase}")&.landing_page_url unless url.present?
    return nil unless url.present?

    %w[/ : & ?].include?(url.last) ? url : "#{url}/"
  end
end
