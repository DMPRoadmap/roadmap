# frozen_string_literal: true

require 'rails_helper'

describe RegistryOrg do
  context 'associations' do
    it { is_expected.to belong_to(:org).optional }
  end

  context 'scopes' do
    before do
      @found = create(:registry_org)
      @not_found = create(:registry_org)
      @term = Faker::Company.unique.name
    end

    it ':by_acronym returns the expected results' do
      @found.update(acronyms: @found.acronyms << @term)
      @not_found.update(acronyms: [])
      results = described_class.by_acronym(@term)
      expect(results.length).to be(1)
      expect(results.first).to eql(@found)
    end

    it ':by_alias returns the expected results' do
      @found.update(aliases: @found.aliases << @term)
      @not_found.update(aliases: [])
      results = described_class.by_alias(@term)
      expect(results.length).to be(1)
      expect(results.first).to eql(@found)
    end

    it ':by_type returns the expected results' do
      @found.update(types: @found.types << @term)
      @not_found.update(types: [])
      results = described_class.by_type(@term)
      expect(results.length).to be(1)
      expect(results.first).to eql(@found)
    end

    it ':by_name returns the expected results' do
      @found.update(name: "#{@found.name} (#{@term})")
      @not_found.update(name: @not_found.name.gsub(@term, ''))
      results = described_class.by_name(@term)
      expect(results.length).to be(1)
      expect(results.first).to eql(@found)
    end

    it ':known returns the expected results' do
      @found.update(org_id: create(:org).id)
      @not_found.update(org_id: nil)
      results = described_class.known
      expect(results.length).to be(1)
      expect(results.first).to eql(@found)
    end

    it ':unknown returns the expected results' do
      @found.update(org_id: create(:org).id)
      @not_found.update(org_id: nil)
      results = described_class.unknown
      expect(results.length).to be(1)
      expect(results.first).to eql(@not_found)
    end

    it ':search calls :by_name, :by_acronym and :by_alias' do
      stubbed = described_class.all
      described_class.expects(:by_name).returns(stubbed)
      described_class.expects(:by_acronym).returns(stubbed)
      described_class.expects(:by_alias).returns(stubbed)
      described_class.send(:search, term: @term)
    end

    describe ':from_email_domain(email_domain:)' do
      it 'returns nil if no :email_domain is present' do
        expect(described_class.send(:from_email_domain, email_domain: nil)).to be_nil
      end

      it 'returns nil if no RegistryOrg matched the :email_domain' do
        expect(described_class.send(:from_email_domain, email_domain: 'foo.bar')).to be_nil
      end

      it 'returns the closest matching RegistryOrg' do
        rorg1 = create(:registry_org)
        create(:registry_org, home_page: "#{rorg1.home_page}.foo")
        result = described_class.send(:from_email_domain, email_domain: rorg1.home_page.upcase)
        expected = rorg1.to_org
        expect(result.name).to eql(expected.name)
        expect(result.abbreviation).to eql(expected.abbreviation)
        expect(result.target_url).to eql(expected.target_url)
      end
    end
  end

  context 'instance methods' do
    before do
      @registry_org = create(:registry_org)
      @scheme = create(:identifier_scheme)
    end

    describe 'to_org' do
      it 'returns the associated org if :org_id is present' do
        org = create(:org)
        @registry_org.org_id = org.id
        expect(@registry_org.to_org).to eql(org)
      end

      it 'correctly initializes the Org' do
        email = Faker::Internet.email
        app_name = Faker::Company.name
        Rails.configuration.x.organisation.helpdesk_email = email
        ApplicationService.stubs(:application_name).returns(app_name)
        result = @registry_org.to_org
        expect(result.is_a?(Org)).to be(true)
        expect(result.name).to eql(@registry_org.name)
        expect(result.contact_email).to eql(email)
        expect(result.contact_name).to eql("#{app_name} helpdesk")
        expect(result.is_other).to be(false)
        expected = JSON.parse("{\"link\":\"#{@registry_org.home_page}\",\"text\":\"Home Page\"}")
        expect(result.links['org'].first).to eql(expected)
        expect(result.managed).to be(false)
        expect(result.target_url).to eql(@registry_org.home_page)
        expect(@registry_org.to_org.abbreviation).to eql(@registry_org.acronyms.first.upcase)
      end

      it 'correctly sets the org_type to :organisation if its not a funder or institution' do
        @registry_org.fundref_id = nil
        @registry_org.types = 'Foo'
        expect(@registry_org.to_org.funder?).to be(false)
        expect(@registry_org.to_org.institution?).to be(false)
        expect(@registry_org.to_org.organisation?).to be(true)
      end

      it 'correctly sets the org_type based on value of :fundref_id' do
        @registry_org.fundref_id = nil
        expect(@registry_org.to_org.funder?).to be(false)
        @registry_org.fundref_id = Faker::Internet.url
        expect(@registry_org.to_org.funder?).to be(true)
      end

      it "correctly sets the org_type based on the existence of 'Education' in :types" do
        @registry_org.types = 'Foo'
        expect(@registry_org.to_org.institution?).to be(false)
        @registry_org.types = @registry_org.types << 'Education'
        expect(@registry_org.to_org.institution?).to be(true)
      end

      it 'expects to call :name_to_abbreviation if no acronyms are available' do
        @registry_org.acronyms = []
        expected = Org.new(name: @registry_org.name).name_to_abbreviation
        expect(@registry_org.to_org.abbreviation).to eql(expected)
      end
    end

    context 'private methods' do
      describe ':ror_or_fundref_to_identifier(scheme_name:, value:)' do
        it 'returns nil if the :org_id is present and :value and :scheme_name are present' do
          @registry_org.update(org_id: create(:org).id)
          result = @registry_org.send(:ror_or_fundref_to_identifier, scheme_name: @scheme.name,
                                                                     value: SecureRandom.uuid)
          expect(result).to be_nil
        end

        it 'returns nil if the :scheme_name does not match an IdentfierScheme' do
          result = @registry_org.send(:ror_or_fundref_to_identifier, scheme_name: 'Foo',
                                                                     value: SecureRandom.uuid)
          expect(result).to be_nil
        end

        it 'returns a new Identifier' do
          @registry_org.update(org_id: nil)
          val = SecureRandom.uuid
          result = @registry_org.send(:ror_or_fundref_to_identifier, scheme_name: @scheme.name,
                                                                     value: val)
          expect(result.identifier_scheme).to eql(@scheme)
          expect(result.value.end_with?(val)).to be(true)
        end
      end
    end
  end
end
