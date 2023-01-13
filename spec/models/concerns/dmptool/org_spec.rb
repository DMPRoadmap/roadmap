# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/ModuleLength
module Dmptool
  RSpec.describe Org do
    include Helpers::IdentifierHelper

    context 'class methods' do
      describe 'participating' do
        it 'returns managed Orgs' do
          managed = create(:org, managed: true)
          unmanaged = create(:org, managed: false)
          results = ::Org.participating
          expect(results.include?(managed)).to be(true)
          expect(results.include?(unmanaged)).to be(false)
        end
      end

      describe 'shibbolized' do
        it 'returns Orgs with an identifier for Shibboleth' do
          shibbolized = create(:org, managed: true)
          managed = create(:org, managed: true)
          unmanaged = create(:org, managed: false)

          create_shibboleth_entity_id(org: shibbolized)
          results = ::Org.shibbolized
          expect(results.include?(shibbolized)).to be(true)
          expect(results.include?(managed)).to be(false)
          expect(results.include?(unmanaged)).to be(false)
        end
      end

      describe 'initialize_from_org_autocomplete(name:, funder: false)' do
        it 'returns nil if the name is not present' do
          expect(::Org.initialize_from_org_autocomplete(name: '')).to be_nil
        end

        it 'returns a new Org based on the :name provided' do
          name = Faker::Company.name
          result = ::Org.initialize_from_org_autocomplete(name: name)
          expect(result.name).to eql(name.split.map(&:capitalize).join(' '))
          expect(result.abbreviation).to eql(result.name_to_abbreviation)
          expect(result.contact_email).to eql(::Org.default_contact_email)
          expect(result.contact_name).to eql(::Org.default_contact_name)
          expect(result.is_other?).to be(false)
          expect(result.managed?).to be(false)
          expect(result.organisation?).to be(true)
          expect(result.funder?).to be(false)
          expect(result.institution?).to be(false)
        end

        it 'sets :institution :org_type if :name includes "college" or "university"' do
          name = Faker::Company.name
          result = ::Org.initialize_from_org_autocomplete(name: "#{name} University")
          expect(result.organisation?).to be(false)
          expect(result.funder?).to be(false)
          expect(result.institution?).to be(true)
        end

        it 'sets :institution :org_type to funder if :funder is true' do
          name = Faker::Company.name
          result = ::Org.initialize_from_org_autocomplete(name: "#{name} University",
                                                          funder: true)
          expect(result.organisation?).to be(false)
          expect(result.funder?).to be(true)
          expect(result.institution?).to be(false)
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
          expect(::Org.from_registry_org!(registry_org: build(:org))).to be_nil
        end

        it 'returns the Org associated with the :registry_org if it already has one' do
          org = create(:org)
          registry_org = create(:registry_org, org: org)
          expect(::Org.from_registry_org!(registry_org: registry_org)).to eql(org)
        end

        it 'returns a new Org and associates it with the :registry_org' do
          ror_scheme
          fundref_scheme
          registry_org = create(:registry_org)
          result = ::Org.from_registry_org!(registry_org: registry_org)
          registry_org.reload

          expect(result.name).to eql(registry_org.name)
          expect(result.abbreviation).to eql(registry_org.acronyms.first.upcase)
          expect(result.contact_email).to eql(::Org.default_contact_email)
          expect(result.contact_name).to eql(::Org.default_contact_name)
          expect(result.is_other?).to be(false)
          expect(result.managed?).to be(false)
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

      describe ':from_email_domain(email_domain:)' do
        it 'returns nil if no :email_domain is present' do
          # expect(Org.send(:from_email_domain, email_domain: nil)).to eql(nil)
          expect(::Org.from_email_domain(email_domain: nil)).to be_nil
        end

        it 'returns nil if :email_domain is one we want to ignore' do
          domain = ApplicationRecord.send(:ignored_email_domains).sample
          # expect(Org.send(:from_email_domain, email_domain: domain)).to eql(nil)
          expect(::Org.from_email_domain(email_domain: domain)).to be_nil
        end

        it 'calls :lookup_registry_org_by_email' do
          RegistryOrg.expects(:from_email_domain).once.returns(@org)
          # expect(Org.send(:from_email_domain, email_domain: 'foo.edu')).to eql(@org)
          expect(::Org.from_email_domain(email_domain: 'foo.edu')).to eql(@org)
        end

        it 'returns nil if no RegitryOrg matched and no other Users with that email domain exist' do
          RegistryOrg.expects(:from_email_domain).once.returns(nil)
          # expect(Org.send(:from_email_domain, email_domain: 'foo.edu')).to eql(nil)
          expect(::Org.from_email_domain(email_domain: 'foo.edu')).to be_nil
        end

        it 'returns the Org with the most User records if there were multiple matches' do
          expected = create(:org)
          domain = 'valid-test-org.edu'
          create(:user, email: "user@#{domain}")
          5.times { create(:user, org: expected, email: "#{Faker::Lorem.unique.word}@#{domain}") }
          RegistryOrg.expects(:from_email_domain).once.returns(nil)
          # There should be 4 Users with the same email domain
          expect(::User.where('email LIKE ?', "%@#{domain.downcase}").count > 3).to be(true)
          # It should return the Org that has 3 Users associated with it
          expect(::Org.send(:from_email_domain, email_domain: domain)).to eql(expected)
        end
      end
    end

    context 'instance methods' do
      describe 'shibbolized?' do
        it 'returns false if the Org is not :managed' do
          scheme = shibboleth_scheme
          org = build(:org, managed: false)
          org.identifiers << build(:identifier, identifier_scheme: scheme)
          expect(org.shibbolized?).to be(false)
        end

        it 'return false if the Org has no Shibboleth entityID' do
          scheme = ror_scheme
          org = build(:org, managed: true)
          org.identifiers << build(:identifier, identifier_scheme: scheme)
          expect(org.shibbolized?).to be(false)
        end

        it 'returns true' do
          scheme = shibboleth_scheme
          org = build(:org, managed: true)
          org.identifiers << build(:identifier, identifier_scheme: scheme)
          expect(org.shibbolized?).to be(true)
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
        before do
          @org = create(:org)
          ror_scheme
          fundref_scheme
        end

        it 'returns true if no RegistryOrg with the same name as the Org exists' do
          expect(@org.connect_to_registry_org).to be(true)
          expect(@org.identifier_for_scheme(scheme: 'ror').present?).to be(false)
          expect(@org.identifier_for_scheme(scheme: 'fundref').present?).to be(false)
        end

        it 'attaches both the ROR and Fundref identifiers to the Org' do
          registry_org = create(:registry_org, name: @org.name)
          expect(@org.connect_to_registry_org).to be(true)
          expect(@org.identifier_for_scheme(scheme: 'ror').value).to eql(registry_org.ror_id)
          expect(@org.identifier_for_scheme(scheme: 'fundref').value).to eql(registry_org.fundref_id)
        end

        it 'associates the Org with the RegistryOrg' do
          registry_org = create(:registry_org, name: @org.name)
          expect(@org.connect_to_registry_org).to be(true)
          expect(registry_org.reload.org_id).to eql(@org.id)
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
