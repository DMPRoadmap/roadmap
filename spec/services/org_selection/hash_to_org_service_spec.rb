# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgSelection::HashToOrgService do
  before(:each) do
    @name = Faker::Company.name
    @abbrev = Faker::Lorem.word.upcase
    @lang = create(:language, abbreviation: Faker::Movies::StarWars.unique.planet.upcase)
    @url = Faker::Internet.url
    @attr_key = Faker::Lorem.word
    @attr_val = Faker::Lorem.word
    @scheme = create(:identifier_scheme, for_orgs: true)

    @hash = {
      name: "#{@name} (#{@abbrev})",
      sort_name: @name,
      score: Faker::Number.number,
      weight: Faker::Number.number,
      language: @lang.abbreviation,
      abbreviation: @abbrev,
      url: @url,
      "#{@scheme.name}": Faker::Lorem.word,
      "#{@attr_key}": @attr_val
    }
  end

  describe '#to_org(hash:)' do
    it 'returns nil if the hash is empty' do
      expect(described_class.to_org(hash: nil)).to eql(nil)
    end
    it 'returns the Org if the hash contains an Org id and the names match' do
      org = create(:org, name: @name)
      @hash[:id] = org.id
      expect(described_class.to_org(hash: @hash)).to eql(org)
    end
    it 'returns the Org by its identifier and the names match' do
      ident = build(:identifier, identifier_scheme: @scheme,
                                 value: @hash[:"#{@scheme.name}"])
      org = create(:org, name: @name, identifiers: [ident])
      expect(described_class.to_org(hash: @hash)).to eql(org)
    end
    it 'returns the Org by name match' do
      org = create(:org, name: @name)
      expect(described_class.to_org(hash: @hash)).to eql(org)
    end
    it 'returns a new Org instance' do
      expect(described_class.to_org(hash: @hash).new_record?).to eql(true)
    end
  end

  describe '#to_identifiers(hash:)' do
    before(:each) do
      @rslt = described_class.to_identifiers(hash: @hash)
    end

    it 'returns an empty array if hash is nil' do
      expect(described_class.to_identifiers(hash: nil)).to eql([])
    end
    it 'skips non-IdentifierScheme entries' do
      @hash.delete(:"#{@scheme.name}")
      expect(described_class.to_identifiers(hash: @hash)).to eql([])
    end
    it 'returns an array of new Identifiers' do
      expect(@rslt.is_a?(Array)).to eql(true)
      expect(@rslt.length).to eql(1)
    end
    it 'returned Identifiers have an identifier scheme' do
      expect(@rslt.first.identifier_scheme).to eql(@scheme)
    end
    it 'returned Identifiers have a value' do
      expect(@rslt.first.value.ends_with?(@hash[:"#{@scheme.name}"])).to eql(true)
    end
    it 'returned Identifiers have attrs' do
      expected = JSON.parse({
        name: @hash[:name],
        url: @url,
        language: @lang.abbreviation,
        abbreviation: @abbrev,
        "#{@attr_key}": @attr_val
      }.to_json)
      expect(JSON.parse(@rslt.first.attrs)).to eql(expected)
    end
  end

  context 'private methods' do
    describe '#initialize_org(hash:)' do
      it 'returns nil if the hash is nil' do
        rslt = described_class.send(:initialize_org, hash: nil)
        expect(rslt).to eql(nil)
      end
      it 'returns nil if the hash has no name attribute' do
        @hash.delete(:name)
        rslt = described_class.send(:initialize_org, hash: @hash)
        expect(rslt).to eql(nil)
      end
      it 'returns a new instance of Org' do
        rslt = described_class.send(:initialize_org, hash: @hash)
        nm = "#{@name} (#{@abbrev})"
        lnks = JSON.parse({ org: [{ link: @url, text: nm }] }.to_json)
        expect(rslt.is_a?(Org)).to eql(true)
        expect(rslt.new_record?).to eql(true)
        expect(rslt.name).to eql(nm)
        expect(rslt.links).to eql(lnks)
        expect(rslt.language).to eql(@lang)
        expect(rslt.target_url).to eql(@url)
        expect(rslt.institution?).to eql(true)
        expect(rslt.abbreviation).to eql(@abbrev)
      end
    end

    describe '#links_from_hash(name:, website:)' do
      before(:each) do
        @dflt = { org: [] }
      end

      it 'returns a default hash if name is blank' do
        rslt = described_class.send(:links_from_hash, name: nil, website: @url)
        expect(rslt).to eql(@dflt)
      end
      it 'returns a default hash if website is blank' do
        rslt = described_class.send(:links_from_hash, name: @name, website: nil)
        expect(rslt).to eql(@dflt)
      end
      it 'returns the links hash' do
        rslt = described_class.send(:links_from_hash, name: @name,
                                                      website: @url)
        expect(rslt).to eql({ org: [{ link: @url, text: @name }] })
      end
    end

    describe '#abbreviation_from_hash(hash:)' do
      it 'returns nil if the hash is nil' do
        rslt = described_class.send(:abbreviation_from_hash, hash: nil)
        expect(rslt).to eql(nil)
      end
      it "returns the hash's abbreviation if it exists" do
        rslt = described_class.send(:abbreviation_from_hash, hash: @hash)
        expect(rslt).to eql(@abbrev)
      end
      it 'returns the name as an acronym (first letter of each word)' do
        @hash.delete(:abbreviation)
        rslt = described_class.send(:abbreviation_from_hash, hash: @hash)
        expected = @name.split.map { |i| i[0].upcase }.join
        expect(rslt).to eql(expected)
      end
    end

    describe '#language_from_hash(hash:)' do
      before(:each) do
        @dflt = Language.default || create(:language, abbreviation: 'org-sel', default_language: true)
      end

      it 'returns the default language if hash is empty' do
        rslt = described_class.send(:language_from_hash, hash: nil)
        expect(rslt).to eql(@dflt)
      end
      it 'returns the default language if hash does not have a :language' do
        rslt = described_class.send(:language_from_hash, hash: {})
        expect(rslt).to eql(@dflt)
      end
      it 'returns the default language if no matching languages exist' do
        @lang.destroy
        rslt = described_class.send(:language_from_hash, hash: @hash)
        expect(rslt).to eql(@dflt)
      end
      it 'returns the correct language' do
        rslt = described_class.send(:language_from_hash, hash: @hash)
        expect(rslt).to eql(@lang)
      end
    end

    describe '#identifier_keys' do
      before(:each) do
        @rslt = described_class.send(:identifier_keys)
      end

      it 'returns the identifier key' do
        expect(@rslt.include?(@scheme.name.to_s)).to eql(true)
      end
      it 'does not return the other keys' do
        expect(@rslt.include?('name')).to eql(false)
        expect(@rslt.include?('sort_name')).to eql(false)
        expect(@rslt.include?('weight')).to eql(false)
        expect(@rslt.include?('score')).to eql(false)
        expect(@rslt.include?('language')).to eql(false)
        expect(@rslt.include?('url')).to eql(false)
        expect(@rslt.include?(@attr_key.to_s)).to eql(false)
      end
    end

    describe '#attr_keys(hash:)' do
      before(:each) do
        @rslt = described_class.send(:attr_keys, hash: JSON.parse(@hash.to_json))
      end

      it 'returns an empty hash if hash is nil' do
        expect(described_class.send(:attr_keys, hash: nil)).to eql({})
      end
      it 'does not include sort_name, weight or score attributes' do
        expect(@rslt.include?('sort_name')).to eql(false)
        expect(@rslt.include?('weight')).to eql(false)
        expect(@rslt.include?('score')).to eql(false)
      end
      it 'does not include identifier keys' do
        expect(@rslt.include?(@scheme.name.to_s)).to eql(false)
      end
      it 'returns the other attributes' do
        expect(@rslt.include?('name')).to eql(true)
        expect(@rslt.include?('language')).to eql(true)
        expect(@rslt.include?('url')).to eql(true)
        expect(@rslt.include?(@attr_key.to_s)).to eql(true)
      end
    end

    describe '#exact_match?(rec:, name2:)' do
      it 'returns false if no record is present' do
        rslt = described_class.send(:exact_match?, rec: nil,
                                                   name2: Faker::Lorem.word)
        expect(rslt).to eql(false)
      end
      it 'returns false if the name is blank' do
        rslt = described_class.send(:exact_match?, rec: build(:org), name2: '')
        expect(rslt).to eql(false)
      end
      it 'calls the SearchService' do
        OrgSelection::SearchService.expects(:exact_match?).at_least(1)
        described_class.send(:exact_match?, rec: build(:org),
                                            name2: Faker::Lorem.word)
      end
    end
  end
end
