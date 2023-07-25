# frozen_string_literal: true

module Helpers
  # rubocop:disable Metrics/ModuleLength
  module IdentifierHelper
    def create_orcid(user:, val: random_orcid)
      scheme = orcid_scheme
      val = append_prefix(scheme: scheme, val: val)
      create(:identifier, identifiable: user, identifier_scheme: scheme, value: val)
    end

    def create_dmp_id(plan:, val: random_doi)
      Rails.configuration.x.madmp.enable_dmp_id_registration = true
      scheme = dmp_id_scheme
      val = append_prefix(scheme: scheme, val: val)
      create(:identifier, identifiable: plan, identifier_scheme: scheme, value: val)
    end

    def create_shibboleth_eppn(user:, val: Faker::Internet.unique.email)
      Rails.configuration.x.shibboleth.enabled = true
      scheme = shibboleth_scheme
      create(:identifier, identifiable: user, identifier_scheme: scheme, value: val)
    end

    def create_shibboleth_entity_id(org:, val: Faker::Internet.unique.url)
      Rails.configuration.x.shibboleth.enabled = true
      scheme = shibboleth_scheme
      create(:identifier, identifiable: org, identifier_scheme: scheme, value: val)
    end

    def create_ror(org:, val: "https://ror.org/#{Faker::Alphanumeric}")
      scheme = ror_scheme
      create(:identifier, identifiable: org, identifier_scheme: scheme, value: val)
    end

    def create_fundref(org:, val: "https://doi.org/10.13039/#{Faker::Alphanumeric}")
      scheme = fundref_scheme
      create(:identifier, identifiable: org, identifier_scheme: scheme, value: val)
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
      name = DmpIdService.identifier_scheme&.name || 'datacite'
      landing_page = DmpIdService.landing_page_url || 'https://doi.org/'
      scheme = IdentifierScheme.find_by(name: name)
      scheme.update(identifier_prefix: landing_page) if scheme.present?
      return scheme if scheme.present?

      create(:identifier_scheme, for_plans: true, name: name, identifier_prefix: landing_page)
    end

    def shibboleth_scheme
      scheme = IdentifierScheme.find_by(name: 'shibboleth')
      return scheme if scheme.present?

      create(:identifier_scheme, for_orgs: true, for_users: true, name: 'shibboleth')
    end

    def ror_scheme
      scheme = IdentifierScheme.find_by(name: 'ror')
      return scheme if scheme.present?

      url = 'https://ror.org/'
      create(:identifier_scheme, for_orgs: true, name: 'ror', identifier_prefix: url)
    end

    def fundref_scheme
      scheme = IdentifierScheme.find_by(name: 'fundref')
      return scheme if scheme.present?

      url = 'https://doi.org/10.13039/'
      create(:identifier_scheme, for_orgs: true, name: 'fundref', identifier_prefix: url)
    end

    def random_orcid
      id = [
        Faker::Number.number(digits: 4),
        Faker::Number.number(digits: 4),
        Faker::Number.number(digits: 4),
        Faker::Number.number(digits: 4)
      ]
      id.join('-')
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
      [shoulder.join('.'), id.join('.')].join('/')
    end

    def doi_scheme
      name = DoiService.scheme_name || 'datacite'
      landing_page = DoiService.landing_page_url || 'https://doi.org/'
      scheme = IdentifierScheme.find_by(name: name)
      scheme.update(identifier_prefix: landing_page) if scheme.present?
      return scheme if scheme.present?

      create(:identifier_scheme, :for_identification, :for_users, name: name,
                                                                  identifier_prefix: landing_page)
    end

    def append_prefix(scheme:, val:)
      val = val[1..val.length] if val.start_with?('/')
      url = landing_page_for(scheme: scheme)
      val.start_with?(url) ? val : "#{url}#{val}"
    end

    def remove_prefix(scheme:, val:)
      val.gsub(landing_page_for(scheme: scheme), '')
    end

    def landing_page_for(scheme:)
      url = scheme.identifier_prefix
      url = Rails.configuration.x.send(:"#{scheme.name.downcase}")&.landing_page_url if url.blank?
      return nil if url.blank?

      %w[/ : & ?].include?(url.last) ? url : "#{url}/"
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
