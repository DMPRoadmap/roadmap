# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/ModuleLength
module Dmptool
  RSpec.describe Org do
    include IdentifierHelper

    context 'class methods' do
      describe 'participating' do
        it 'returns managed Orgs' do
          managed = create(:org, managed: true)
          unmanaged = create(:org, managed: false)
          results = ::Org.participating
          expect(results.include?(managed)).to eql(true)
          expect(results.include?(unmanaged)).to eql(false)
        end
      end

      describe 'shibbolized' do
        it 'returns Orgs with an identifier for Shibboleth' do
          shibbolized = create(:org, managed: true)
          managed = create(:org, managed: true)
          unmanaged = create(:org, managed: false)

          create_shibboleth_entity_id(org: shibbolized)
          results = ::Org.shibbolized
          expect(results.include?(shibbolized)).to eql(true)
          expect(results.include?(managed)).to eql(false)
          expect(results.include?(unmanaged)).to eql(false)
        end
      end

      describe 'initialize_from_org_autocomplete(name:, funder: false)' do
        it 'returns nil if the name is not present' do
          expect(::Org.initialize_from_org_autocomplete(name: '')).to eql(nil)
        end
        it 'returns a new Org based on the :name provided' do
          name = Faker::Company.name
          result = ::Org.initialize_from_org_autocomplete(name: name)
          expect(result.name).to eql(name.split.map(&:capitalize).join(' '))
          expect(result.abbreviation).to eql(result.name_to_abbreviation)
          expect(result.contact_email).to eql(::Org.default_contact_email)
          expect(result.contact_name).to eql(::Org.default_contact_name)
          expect(result.is_other?).to eql(false)
          expect(result.managed?).to eql(false)
          expect(result.organisation?).to eql(true)
          expect(result.funder?).to eql(false)
          expect(result.institution?).to eql(false)
        end
        it 'sets :institution :org_type if :name includes "college" or "university"' do
          name = Faker::Company.name
          result = ::Org.initialize_from_org_autocomplete(name: "#{name} University")
          expect(result.organisation?).to eql(false)
          expect(result.funder?).to eql(false)
          expect(result.institution?).to eql(true)
        end
        it 'sets :institution :org_type to funder if :funder is true' do
          name = Faker::Company.name
          result = ::Org.initialize_from_org_autocomplete(name: "#{name} University",
                                                          funder: true)
          expect(result.organisation?).to eql(false)
          expect(result.funder?).to eql(true)
          expect(result.institution?).to eql(false)
        end
      end

      describe 'name_to_abbreviation(name:)' do
        it 'returns an empty string if name is not present' do
          expect(::Org.name_to_abbreviation(name: nil)).to eql('')
        end
        it 'calls the :name_to_abbreviation instance method' do
          ::Org.any_instance.expects(:name_to_abbreviation).once
          ::Org.name_to_abbreviation(name: Faker::Company.name)
        end
      end

      describe 'from_registry_org!(registry_org:)' do
        it 'returns nil if :registry_org is not a RegistryOrg' do
          expect(::Org.from_registry_org!(registry_org: build(:org))).to eql(nil)
        end
        it 'returns the Org associated with the :registry_org if it already has one' do
          org = create(:org)
          registry_org = create(:registry_org, org: org)
          expect(::Org.from_registry_org!(registry_org: registry_org)).to eql(org)
        end
        it 'returns a new Org and associates it with the :registry_org' do
          Rails.configuration.x.organisation.helpdesk_email = Faker::Internet.unique.email
          ror_scheme
          fundref_scheme
          registry_org = create(:registry_org)
          result = ::Org.from_registry_org!(registry_org: registry_org)
          registry_org.reload

          expect(result.name).to eql(registry_org.name)
          expect(result.abbreviation).to eql(registry_org.acronyms.first.upcase)
          expect(result.contact_email).to eql(::Org.default_contact_email)
          expect(result.contact_name).to eql(::Org.default_contact_name)
          expect(result.is_other?).to eql(false)
          expect(result.managed?).to eql(false)
          expect(result.target_url).to eql(registry_org.home_page)
          links = { org: [{ link: registry_org.home_page, text: 'Home Page' }] }.to_json
          expect(result.links).to eql(JSON.parse(links))
          expect(result.funder?).to eql(registry_org.fundref_id.present?)
          expect(result.institution?).to eql(registry_org.types.include?('Education'))
          expect(result.organisation?).to eql(!result.funder? && !result.institution?)
          expect(registry_org.org_id).to eql(result.id)
          ror = result.identifier_for_scheme(scheme: 'ror')
          fundref = result.identifier_for_scheme(scheme: 'fundref')
          expect(ror.value).to eql(registry_org.ror_id)
          expect(fundref.value).to eql(registry_org.fundref_id)
        end
      end
    end

    context 'instance methods' do
      describe 'shibbolized?' do
        it 'returns false if the Org is not :managed' do
          scheme = shibboleth_scheme
          org = build(:org, managed: false)
          org.identifiers << build(:identifier, identifier_scheme: scheme)
          expect(org.shibbolized?).to eql(false)
        end
        it 'return false if the Org has no Shibboleth entityID' do
          scheme = ror_scheme
          org = build(:org, managed: true)
          org.identifiers << build(:identifier, identifier_scheme: scheme)
          expect(org.shibbolized?).to eql(false)
        end
        it 'returns true' do
          scheme = shibboleth_scheme
          org = build(:org, managed: true)
          org.identifiers << build(:identifier, identifier_scheme: scheme)
          expect(org.shibbolized?).to eql(true)
        end
      end

      describe 'name_without_alias' do
        it 'returns the name as is if the name has no part in parenthesis' do
          org = build(:org, name: 'foo BAR')
          expect(org.name_without_alias).to eql('foo BAR')
        end
        it 'strips out the part in parenthesis' do
          org = build(:org, name: 'foo BAR (foo.bar)')
          expect(org.name_without_alias).to eql('foo BAR')
        end
      end

      describe 'name_to_abbreviation' do
        it 'ignores stop words' do
          org = build(:org, name: 'Foo And Bar')
          expect(org.name_to_abbreviation).to eql('FB')
        end
        it 'converts the 1st letter of each word to capital' do
          org = build(:org, name: 'foo 123 BAR')
          expect(org.name_to_abbreviation).to eql('F1B')
        end
      end

      describe 'connect_to_registry_org' do
        before(:each) do
          @org = create(:org)
          ror_scheme
          fundref_scheme
        end

        it 'returns true if no RegistryOrg with the same name as the Org exists' do
          expect(@org.connect_to_registry_org).to eql(true)
          expect(@org.identifier_for_scheme(scheme: 'ror').present?).to eql(false)
          expect(@org.identifier_for_scheme(scheme: 'fundref').present?).to eql(false)
        end
        it 'attaches both the ROR and Fundref identifiers to the Org' do
          registry_org = create(:registry_org, name: @org.name)
          expect(@org.connect_to_registry_org).to eql(true)
          expect(@org.identifier_for_scheme(scheme: 'ror').value).to eql(registry_org.ror_id)
          expect(@org.identifier_for_scheme(scheme: 'fundref').value).to eql(registry_org.fundref_id)
        end
        it 'associates the Org with the RegistryOrg' do
          registry_org = create(:registry_org, name: @org.name)
          expect(@org.connect_to_registry_org).to eql(true)
          expect(registry_org.reload.org_id).to eql(@org.id)
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
