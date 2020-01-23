# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgSelection::SearchService do

  before(:each) do
    @org = create(:org, name: "Fooville Community College", is_other: false)
    @ror_records = [
      {
        id: Faker::Internet.url,
        name: "Foo College (test.edu)",
        sort_name: "Foo College"
      },
      {
        id: Faker::Internet.url,
        name: "Foo College (other.edu)",
        sort_name: "Foo College"
      },
      {
        id: Faker::Internet.url,
        name: "Foo University (Ireland)",
        sort_name: "Foo University"
      },
      {
        id: Faker::Internet.url,
        name: "University of Foo (Spain)",
        sort_name: "University of Foo"
      }
    ]
    @records = @ror_records + [@org]

    # Mock calls to the RorService
    ExternalApis::RorService.stubs(:active).returns(true)
    ExternalApis::RorService.stubs(:search).returns(@ror_records)
  end

  describe "#search" do
    it "returns an empty array if the search term is blank" do
      expect(described_class.search(search_term: nil)).to eql([])
    end
    it "returns an empty array if the search term is less than 3 characters" do
      expect(described_class.search(search_term: "Fo")).to eql([])
    end
    it "includes the local DB records and excludes external APIs by default" do
      rslts = described_class.search(search_term: "Foo")
      expect(rslts.length).to eql(1)
      expect(rslts.first[:id]).to eql(@org.id)
    end
    it "skips the local DB records if specified" do
      rslts = described_class.search(search_term: "Foo", include_locals: false)
      expect(rslts.length).to eql(0)
    end
    it "includes the external API records if specified" do
      rslts = described_class.search(search_term: "Foo", include_externals: true)
      expect(rslts.length).to eql(4)
    end
    it "skips the external APIs if we had a local exact_match" do
      term = "Fooville Community College (FOO)"
      rslts = described_class.search(search_term: term, include_externals: true)
      expect(rslts.length).to eql(1)
      expect(rslts.first[:id]).to eql(@org.id)
    end
  end

  describe "#convert_hash_to_org" do
    before(:each) do
      @scheme = create(:identifier_scheme)
      identifier = Faker::Lorem.unique.word
      OrgIdentifier.create(org_id: @org.id, identifier: identifier,
                           identifier_scheme_id: @scheme.id)
      @hash = {
        "id": @org.id.to_s,
        "name": "#{@org.name} (#{Faker::Lorem.word.upcase})",
        "#{@scheme.name.downcase}": identifier
      }
    end

    it "initializes a new Org" do
      ident = Faker::Lorem.unique.word
      hash = {
        "name": Faker::Lorem.sentence,
        "#{@scheme.name.downcase}": ident
      }
      rslt = described_class.send(:convert_hash_to_org, hash: hash)
      expect(rslt.name).to eql(hash[:name])
      expect(rslt.org_identifiers.first.identifier).to eql(ident)
    end

    context "finds an existing Org" do
      context "by id" do
        before(:each) do
          @hash[:"#{@scheme.name.downcase}"] = ""
        end

        it "finds an Org" do
          rslt = described_class.send(:convert_hash_to_org, hash: @hash)
          expect(rslt).to eql(@org)
        end
        it "initializes a new Org if the names do not match" do
          @hash[:name] = Faker::Lorem.sentence
          rslt = described_class.send(:convert_hash_to_org, hash: @hash)
          expect(rslt.new_record?).to eql(true)
        end
      end
      context "by org_identifier" do
        before(:each) do
          @hash[:id] = ""
        end

        it "finds an Org" do
          rslt = described_class.send(:convert_hash_to_org, hash: @hash)
          expect(rslt).to eql(@org)
        end
        it "initializes a new Org if the names do not match" do
          @hash[:name] = Faker::Lorem.sentence
          rslt = described_class.send(:convert_hash_to_org, hash: @hash)
          expect(rslt.new_record?).to eql(true)
        end
      end
      context "by name" do
        before(:each) do
          @hash[:"#{@scheme.name.downcase}"] = ""
          @hash[:id] = ""
        end

        it "finds an Org" do
          rslt = described_class.send(:convert_hash_to_org, hash: @hash)
          expect(rslt).to eql(@org)
        end
        it "initializes a new Org if the names do not match" do
          @hash[:name] = Faker::Lorem.sentence
          rslt = described_class.send(:convert_hash_to_org, hash: @hash)
          expect(rslt.new_record?).to eql(true)
        end
      end
    end
  end

  describe "#convert_org_to_hash" do
    before(:each) do
      @org.name = "#{@org.name} (example.org)"
      @rslt = described_class.send(:convert_org_to_hash, org: @org)
    end

    it "returns an empty hash if the incoming org is not an Org" do
      expect(described_class.send(:convert_org_to_hash, org: nil)).to eql({})
    end
    it "converts the Org to a hash" do
      expect(@rslt.is_a?(Hash)).to eql(true)
    end
    it "the converted hash has the Org's id" do
      expect(@rslt[:id]).to eql(@org.id)
    end
    it "the converted hash has the Org's name" do
      expect(@rslt[:name]).to eql(@org.name)
    end
    it "the converted hash properly removes the Org's abbreviation if present" do
      expect(@rslt[:sort_name]).to eql(@org.name.gsub(" (example.org)", ""))
    end
  end

  context "private methods" do

    describe "#local_search" do
      it "returns an empty array if the search term is blank" do
        rslts = described_class.send(:local_search, search_term: nil)
        expect(rslts).to eql([])
      end
      it "returns an empty array if no Orgs were matched" do
        rslts = described_class.send(:local_search, search_term: "Bar")
        expect(rslts).to eql([])
      end
      it "returns an array of matching Orgs" do
        rslts = described_class.send(:local_search, search_term: "Foo")
        expect(rslts.length).to eql(1)
        expect(rslts.is_a?(Array)).to eql(true)
      end
    end

    describe "#externals_search" do
      before(:each) do
        ExternalApis::RorService.stubs(:active).returns(true)
      end

      it "returns an empty array if the search term is blank" do
        rslts = described_class.send(:externals_search, search_term: nil)
        expect(rslts).to eql([])
      end
      it "returns an empty array if no external apis are active" do
        ExternalApis::RorService.stubs(:active).returns(false)
        rslts = described_class.send(:externals_search, search_term: "Foo")
        expect(rslts).to eql([])
      end
      it "returns an empty array if no Orgs were matched" do
        ExternalApis::RorService.stubs(:search).returns([])
        rslts = described_class.send(:externals_search, search_term: "Foo")
        expect(rslts).to eql([])
      end
      it "returns an array of matching Orgs" do
        rslts = described_class.send(:externals_search, search_term: "Foo")
        expect(rslts.length).to eql(4)
        expect(rslts.is_a?(Array)).to eql(true)
      end
    end

    describe "#prepare" do
      it "returns an empty array if the search term is blank" do
        rslts = described_class.send(:prepare, search_term: nil, records: @records)
        expect(rslts).to eql([])
      end
      it "returns an empty array if the records is not an array" do
        rslts = described_class.send(:prepare, search_term: "Foo", records: nil)
        expect(rslts).to eql([])
      end
      it "handles Org models" do
        rslts = described_class.send(:prepare, search_term: "Foo", records: @records)
        rec = rslts.select { |item| item[:name].include?("Community") }.first
        expect(rec[:name]).to eql("Fooville Community College")
      end
      it "handles non-Org models" do
        rslts = described_class.send(:prepare, search_term: "Foo", records: @records)
        rec = rslts.select { |item| item[:name].include?("Ireland") }.first
        expect(rec[:name]).to eql("Foo University (Ireland)")
      end
    end

    describe "#deduplicate" do
      it "returns an empty array if the incoming records is not an Array" do
        expect(described_class.send(:deduplicate, records: nil)).to eql([])
      end
      it "includes all of the unique records" do
        rslts = described_class.send(:deduplicate, records: @ror_records)
        expect(rslts.length).to eql(3)
      end
      it "removes the duplicate" do
        rslts = described_class.send(:deduplicate, records: @ror_records)
        dupe = rslts.select { |rec| rec[:name] == "Foo College (other.edu)" }
        expect(dupe).to eql([])
      end
    end

    describe "#sort" do
      before(:each) do
        @sortable = @ror_records.each_with_index.map do |rec, idx|
          rec.merge(weight: idx, score: idx + 1)
        end
        # Mix up the records since we scored them in order
        @sortable = @sortable.sort { |a, b| b[:name] <=> a[:name] }
      end

      it "returns an empty array if the incoming array is not an Array" do
        expect(described_class.send(:sort, array: nil)).to eql([])
      end
      it "places the record with the lowest score + weight first" do
        rslts = described_class.send(:sort, array: @sortable)
        expect(rslts.first[:score]).to eql(1)
        expect(rslts.first[:weight]).to eql(0)
      end
      it "places the record with the highest score+ weight last" do
        rslts = described_class.send(:sort, array: @sortable)
        expect(rslts.last[:score]).to eql(4)
        expect(rslts.last[:weight]).to eql(3)
      end
      it "sorts by name ascending when the score and weight match" do
        @sortable[1][:score] = 0
        @sortable[1][:weight] = 0
        @sortable[2][:score] = 0
        @sortable[2][:weight] = 0

        rslts = described_class.send(:sort, array: @sortable)
        expect(rslts[0][:sort_name].include?("College")).to eql(true)
        expect(rslts[1][:sort_name].include?("University")).to eql(true)
      end
    end

    describe "#evaluate" do
      before(:each) do
        described_class.stubs(:score).returns(0)
        described_class.stubs(:weigh).returns(0)
        @record = @ror_records.first
      end
      it "returns the record if search term is nil" do
        rslt = described_class.send(:evaluate, record: @record, search_term: nil)
        expect(rslt).to eql(@record)
      end
      it "returns a nil if record is nil" do
        rslt = described_class.send(:evaluate, record: nil, search_term: "Foo")
        expect(rslt).to eql(nil)
      end
      it "adds a score to each item" do
        rslt = described_class.send(:evaluate, record: @record, search_term: "Foo")
        expect(rslt[:score]).to eql(0)
      end
      it "adds a weight to each item" do
        rslt = described_class.send(:evaluate, record: @record, search_term: "Foo")
        expect(rslt[:weight]).to eql(0)
      end
    end

    describe "#score" do
      it "returns a high value '99' if term is nil" do
        rslt = described_class.send(:score, search_term: nil, item_name: "Foo")
        expect(rslt).to eql(99)
      end
      it "returns a high value '99' if item_name is nil" do
        rslt = described_class.send(:score, search_term: "Foo", item_name: nil)
        expect(rslt).to eql(99)
      end
      it "calls the base class' natuaral language comparison method" do
        Text::Levenshtein.stubs(:distance).returns(0)
        rslt = described_class.send(:score, search_term: "Foo", item_name: "Bar")
        expect(rslt).to eql(0)
      end
    end

    describe "#weigh" do
      before(:each) do
        @term = Faker::Lorem.word
      end
      it "expects a weight of 3 if the search_term is blank" do
        rslt = described_class.send(:weigh, search_term: nil, item_name: @term)
        expect(rslt).to eql(3)
      end
      it "expects a weight of 3 if the search_term is blank" do
        rslt = described_class.send(:weigh, search_term: @term, item_name: nil)
        expect(rslt).to eql(3)
      end
      it "expects a result that starts with the search term to weigh zero" do
        item = "#{@term.downcase}#{Faker::Lorem.sentence}"
        rslt = described_class.send(:weigh, search_term: @term, item_name: item)
        expect(rslt).to eql(0)
      end
      it "expects a result that contains the search term to weigh one" do
        item = "#{Faker::Lorem.sentence}#{@term.downcase}"
        rslt = described_class.send(:weigh, search_term: @term, item_name: item)
        expect(rslt).to eql(1)
      end
      it "expects a result that does not contain the search term to weigh two" do
        item = Faker::Lorem.sentence.to_s.gsub(@term, "foo bar")
        rslt = described_class.send(:weigh, search_term: @term, item_name: item)
        expect(rslt).to eql(2)
      end
    end

    describe "#filter" do
      it "returns an empty array if the array in is not an Array" do
        expect(described_class.send(:filter, array: nil)).to eql([])
      end
      it "returns all records if they do not have a 'score'" do
        expect(described_class.send(:filter, array: @records).length).to eql(5)
      end
      it "discards any item whose score is > 25" do
        recs = @records.map { |rec| rec.is_a?(Org) ? rec : rec.merge(score: 26) }
        expect(described_class.send(:filter, array: recs).length).to eql(1)
      end
    end

    describe "#name_without_alias" do
      it "returns an empty string if the specified name is nil" do
        expect(described_class.send(:name_without_alias, name: nil)).to eql("")
      end
      it "returns an empty string if the name only contains parenthesis content" do
        rslt = described_class.send(:name_without_alias, name: "  (foo) ")
        expect(rslt).to eql("")
      end
      it "returns the name sans parenthesis content" do
        rslt = described_class.send(:name_without_alias, name: "  Foo  (bar)")
        expect(rslt).to eql("Foo")
      end
    end

    describe "#exact_match?" do
      it "returns false if name1 is nil" do
        rslt = described_class.send(:exact_match?, name1: nil, name2: "Foo")
        expect(rslt).to eql(false)
      end
      it "returns false if name2 is nil" do
        rslt = described_class.send(:exact_match?, name1: "Foo", name2: nil)
        expect(rslt).to eql(false)
      end
      it "returns false if the names do not match" do
        rslt = described_class.send(:exact_match?, name1: "Bar", name2: "Foo")
        expect(rslt).to eql(false)
      end
      it "returns true if the names match" do
        rslt = described_class.send(:exact_match?, name1: "Foo", name2: "Foo")
        expect(rslt).to eql(true)
      end
      it "returns true if the names match but their cases do not" do
        rslt = described_class.send(:exact_match?, name1: "foo", name2: "Foo")
        expect(rslt).to eql(true)
      end
    end

    describe "#init_org_from_hash(hash:)" do
      it "returns nil if hash is nil" do
        rslt = described_class.send(:init_org_from_hash, hash: nil)
        expect(rslt).to eql(nil)
      end
      it "returns nil if no name is in the hash" do
        rslt = described_class.send(:init_org_from_hash, hash: { id: "1" })
        expect(rslt).to eql(nil)
      end
      it "returns a new instance of an Org" do
        hash = { name: Faker::Company.name }
        rslt = described_class.send(:init_org_from_hash, hash: hash)
        expect(rslt.name).to eql(hash[:name])
        expect(rslt.institution).to eql(true)
        expect(rslt.is_other).to eql(false)
      end
      it "returns a new instance of an Org with identifiers" do
        scheme = create(:identifier_scheme)
        hash = { name: Faker::Company.name, "#{scheme.name.downcase}": "1" }
        rslt = described_class.send(:init_org_from_hash, hash: hash)
        expect(rslt.org_identifiers.length).to eql(1)
      end
    end

    describe "#links_from_hash(name:, website:)" do
      before(:each) do
        @url = Faker::Internet.url,
               @name = Faker::Company.name
      end

      it "returns the empty stub if name is blank" do
        rslt = described_class.send(:links_from_hash, name: nil,
                                                      website: @url)
        expect(rslt).to eql("org": [])
      end
      it "returns the empty stub if website is blank" do
        rslt = described_class.send(:links_from_hash, name: @name,
                                                      website: nil)
        expect(rslt).to eql("org": [])
      end
      it "converts the hash to Org links" do
        rslt = described_class.send(:links_from_hash, name: @name,
                                                      website: @url)
        expect(rslt).to eql("org": [{ "link": @url, "text": @name }])
      end
    end

    describe "#abbreviation_from_hash(hash:)" do
      it "returns nil if the hash is nil" do
        rslt = described_class.send(:abbreviation_from_hash, hash: nil)
        expect(rslt).to eql(nil)
      end
      it "returns the specified abbreviation" do
        hash = { name: "Test Abbreviation function", abbreviation: "ABC" }
        rslt = described_class.send(:abbreviation_from_hash, hash: hash)
        expect(rslt).to eql("ABC")
      end
      it "returns the first letter of each word in the name" do
        hash = { name: "Test Abbreviation function" }
        rslt = described_class.send(:abbreviation_from_hash, hash: hash)
        expect(rslt).to eql("TAF")
      end
    end

    describe "#language_from_hash(hash:)" do
      before(:each) do
        @default_lang = create(:language, default_language: true)
      end

      it "returns the default language if the hash is nil" do
        rslt = described_class.send(:language_from_hash, hash: nil)
        expect(rslt).to eql(@default_lang)
      end
      it "returns the default language if no language is specified" do
        hash = { name: Faker::Company.name }
        rslt = described_class.send(:language_from_hash, hash: hash)
        expect(rslt).to eql(@default_lang)
      end
      it "returns the specified language" do
        lang = create(:language, default_language: false)
        hash = {
          name: "Test Abbreviation function",
          language: lang.abbreviation
        }
        rslt = described_class.send(:language_from_hash, hash: hash)
        expect(rslt).to eql(lang)
      end
    end

  end

end
