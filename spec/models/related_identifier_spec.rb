# frozen_string_literal: true

require 'rails_helper'

describe RelatedIdentifier do
  context 'validations' do
    it { is_expected.to validate_presence_of(:value) }

    it { is_expected.to validate_presence_of(:identifiable) }

    it { is_expected.to define_enum_for(:work_type).with_values(RelatedIdentifier.work_types.keys) }

    it { is_expected.to define_enum_for(:relation_type).with_values(RelatedIdentifier.relation_types.keys) }

    it { is_expected.to define_enum_for(:identifier_type).with_values(RelatedIdentifier.identifier_types.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:identifiable) }

    it { is_expected.to belong_to(:identifier_scheme).optional }
  end

  describe ':value_without_scheme_prefix' do
    before(:each) do
      @scheme = build(:identifier_scheme, identifier_prefix: Faker::Internet.unique.url)
    end

    it 'returns :value as-is if no IdentifierScheme is present' do
      id = build(:related_identifier, identifier_scheme: nil)
      expect(id.value_without_scheme_prefix).to eql(id.value)
    end
    it 'returns :value as-is if the IdentifierScheme has no :identifier_prefix' do
      @scheme.identifier_prefix = nil
      id = build(:related_identifier, identifier_scheme: @scheme)
      expect(id.value_without_scheme_prefix).to eql(id.value)
    end
    it 'strips off the :identifier_prefix defined by the IdentifierScheme' do
      id = build(:related_identifier, identifier_scheme: @scheme,
                                      value: "#{@scheme.identifier_prefix}foo")
      expect(id.value_without_scheme_prefix).to eql('foo')
    end
  end

  context 'private methods' do
    before(:each) do
      @id = build(:related_identifier)
    end

    it ':ensure_defaults callback executes the correct methods' do
      @id.expects(:detect_identifier_type).once
      @id.expects(:detect_relation_type).once
      @id.send(:ensure_defaults)
    end

    describe ':detect_identifier_type' do
      it "returns 'doi' if the value matches the DOI regexp" do
        @id.value = 'https://doi.org/10.123/abc'
        expect(@id.send(:detect_identifier_type)).to eql('doi')
        @id.value = 'http://dx.doi.org/10.123/abc'
        expect(@id.send(:detect_identifier_type)).to eql('doi')
        @id.value = '10.123/abc'
        expect(@id.send(:detect_identifier_type)).to eql('doi')
        @id.value = 'doi:10.1234/abc'
        expect(@id.send(:detect_identifier_type)).to eql('doi')
      end
      it "returns 'ark' if the value matches the ARK regexp" do
        @id.value = 'http://example.org/ark:12345/abcd'
        expect(@id.send(:detect_identifier_type)).to eql('ark')
        @id.value = 'ark:12345/abcd'
        expect(@id.send(:detect_identifier_type)).to eql('ark')
      end
      it "returns 'url' if the value matches the URL regexp" do
        @id.value = 'https://example.org'
        expect(@id.send(:detect_identifier_type)).to eql('url')
        @id.value = 'http://example.org'
        expect(@id.send(:detect_identifier_type)).to eql('url')
      end
      it "returns 'other' if the value did not match another regexp" do
        @id.value = 'example.org'
        expect(@id.send(:detect_identifier_type)).to eql('other')
        @id.value = '348th9834t'
        expect(@id.send(:detect_identifier_type)).to eql('other')
      end
    end

    describe ':detect_relation_type' do
      it 'returns \'cites\' by default if no :relation_type is defined' do
        @id.relation_type = nil
        expect(@id.send(:detect_relation_type)).to eql('cites')
      end
      it 'returns the :relation_type' do
        val = RelatedIdentifier.relation_types.keys
                               .reject { |k| k == 'is_referenced_by' }.first
        @id.relation_type = val
        expect(@id.send(:detect_relation_type)).to eql(val)
      end
    end

    describe ':load_citation' do
      before(:each) do
        @id.citation = nil
        @id.identifier_type = 'doi'
        @citation = Faker::Lorem.paragraph
      end

      it 'does not process if the config is disabled' do
        Rails.configuration.x.madmp.enable_citation_lookup = false
        @id.expects(:fetch_citation).never
        @id.send(:load_citation)
        expect(@id.citation).to eql(nil)
      end
      it 'does not process if a :citation already exists' do
        Rails.configuration.x.madmp.enable_citation_lookup = true
        @id.expects(:fetch_citation).never
        @id.citation = @citation
        @id.send(:load_citation)
        expect(@id.citation).to eql(@citation)
      end
      it "does not process if a the :value is not a 'doi'" do
        Rails.configuration.x.madmp.enable_citation_lookup = true
        @id.expects(:fetch_citation).never
        @id.identifier_type = 'url'
        @id.send(:load_citation)
        expect(@id.citation).to eql(nil)
      end
      it "calls out to the Uc3Citation gem's :fetch_citation method" do
        Rails.configuration.x.madmp.enable_citation_lookup = true
        @id.expects(:fetch_citation).returns(@citation)
        @id.send(:load_citation)
        expect(@id.citation).to eql(@citation)
      end
    end
  end
end
