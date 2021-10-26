# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgSelection::SearchService do

  before(:each) do
    @records = [
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

    # Mock calls to the RorService
    ExternalApis::RorService.stubs(:active?).returns(true)
    ExternalApis::RorService.stubs(:search).returns(@records)
  end

  describe "#search_combined(search_term:)" do
    it "returns an empty array if the search term is not provided" do
      expect(described_class.search_combined(search_term: nil)).to eql([])
    end
    it "returns an empty array if the search term is less than 2 chars" do
      expect(described_class.search_combined(search_term: "Ab")).to eql([])
    end
    it "only searches locally if an exact match was found" do
      org = create(:org)
      described_class.expects(:local_search).returns([org]).at_least(1)
      described_class.expects(:externals_search).at_least(0)
      described_class.search_combined(search_term: org.name)
    end
    it "calls both search_locally and search_externally" do
      described_class.expects(:local_search).at_least(1)
      described_class.expects(:externals_search).at_least(1)
      described_class.search_combined(search_term: Faker::Company.name)
    end
  end

  describe "#search_externally(search_term:)" do
    it "returns an empty array if the search term is not provided" do
      expect(described_class.search_externally(search_term: nil)).to eql([])
    end
    it "returns an empty array if the search term is less than 2 chars" do
      expect(described_class.search_externally(search_term: "Ab")).to eql([])
    end
    it "calls the private externals_search method" do
      described_class.expects(:externals_search).at_least(1)
      described_class.search_externally(search_term: Faker::Company.name)
    end
  end

  describe "#search_locally(search_term:)" do
    it "returns an empty array if the search term is not provided" do
      expect(described_class.search_locally(search_term: nil)).to eql([])
    end
    it "returns an empty array if the search term is less than 2 chars" do
      expect(described_class.search_locally(search_term: "Ab")).to eql([])
    end
    it "calls the private locals_search method" do
      described_class.expects(:local_search).at_least(1)
      described_class.search_locally(search_term: Faker::Company.name)
    end
  end

  describe "#name_without_alias(name:)" do
    it "returns an empty string if name is not present" do
      expect(described_class.name_without_alias(name: nil)).to eql("")
    end
    it "returns the name without the abbreviation alias" do
      name = Faker::Company.name
      rslt = described_class.name_without_alias(name: "#{name} (ABC)")
      expect(rslt).to eql(name)
    end
    it "returns the name without the domain alias" do
      name = Faker::Company.name
      rslt = described_class.name_without_alias(name: "#{name} (example.edu)")
      expect(rslt).to eql(name)
    end
  end

  describe "#exact_match?(name1:, name2:)" do
    it "returns false if name1 is nil" do
      rslt = described_class.exact_match?(name1: nil, name2: "Foo")
      expect(rslt).to eql(false)
    end
    it "returns false if name2 is nil" do
      rslt = described_class.exact_match?(name1: "Foo", name2: nil)
      expect(rslt).to eql(false)
    end
    it "returns false if the names do not match" do
      rslt = described_class.exact_match?(name1: "Bar", name2: "Foo")
      expect(rslt).to eql(false)
    end
    it "returns true if the names match" do
      rslt = described_class.exact_match?(name1: "Foo", name2: "Foo")
      expect(rslt).to eql(true)
    end
    it "returns true if the names match but their cases do not" do
      rslt = described_class.exact_match?(name1: "foo", name2: "Foo")
      expect(rslt).to eql(true)
    end
  end

  context "private methods" do

    describe "#local_search(search_term:)" do
      it "returns an empty array if the search term is blank" do
        rslts = described_class.send(:local_search, search_term: nil)
        expect(rslts).to eql([])
      end
      it "returns an empty array if no Orgs were matched" do
        rslts = described_class.send(:local_search, search_term: "Bar")
        expect(rslts).to eql([])
      end
      it "returns an array of matching Orgs" do
        create(:org, name: "Foo Bar")
        rslts = described_class.send(:local_search, search_term: "Foo")
        expect(rslts.length).to eql(1)
        expect(rslts.is_a?(Array)).to eql(true)
      end
    end

    describe "#externals_search(search_term:)" do
      before(:each) do
        ExternalApis::RorService.stubs(:active?).returns(true)
      end

      it "returns an empty array if the search term is blank" do
        rslts = described_class.send(:externals_search, search_term: nil)
        expect(rslts).to eql([])
      end
      it "returns an empty array if no external apis are active" do
        ExternalApis::RorService.stubs(:active?).returns(false)
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

    describe "#prepare(search_term:, records:)" do
      it "returns an empty array if the search term is blank" do
        rslts = described_class.send(:prepare, search_term: nil,
                                               records: @records)
        expect(rslts).to eql([])
      end
      it "returns an empty array if the records is not an array" do
        rslts = described_class.send(:prepare, search_term: "Foo",
                                               records: nil)
        expect(rslts).to eql([])
      end
      it "handles Org models" do
        recs = [create(:org, name: "Fooville Community College")]
        rslts = described_class.send(:prepare, search_term: "Foo",
                                               records: recs)
        expect(rslts.first[:name]).to eql("Fooville Community College")
      end
      it "handles non-Org models" do
        rslts = described_class.send(:prepare, search_term: "Foo",
                                               records: @records)
        rec = rslts.select { |item| item[:name].include?("Ireland") }.first
        expect(rec[:name]).to eql("Foo University (Ireland)")
      end
    end

    describe "#deduplicate(records:)" do
      it "returns an empty array if the incoming records is not an Array" do
        expect(described_class.send(:deduplicate, records: nil)).to eql([])
      end
      it "includes all of the unique records" do
        rslts = described_class.send(:deduplicate, records: @records)
        expect(rslts.length).to eql(3)
      end
      it "removes the duplicate" do
        rslts = described_class.send(:deduplicate, records: @records)
        dupe = rslts.select { |rec| rec[:name] == "Foo College (other.edu)" }
        expect(dupe).to eql([])
      end
    end

    describe "#sort(array:)" do
      before(:each) do
        @sortable = @records.each_with_index.map do |rec, idx|
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

    describe "#evaluate(reord:, search_term:)" do
      before(:each) do
        described_class.stubs(:score).returns(0)
        described_class.stubs(:weigh).returns(0)
        @record = @records.first
      end
      it "returns the record if search term is nil" do
        rslt = described_class.send(:evaluate, record: @record,
                                               search_term: nil)
        expect(rslt).to eql(@record)
      end
      it "returns a nil if record is nil" do
        rslt = described_class.send(:evaluate, record: nil,
                                               search_term: "Foo")
        expect(rslt).to eql(nil)
      end
      it "adds a score to each item" do
        rslt = described_class.send(:evaluate, record: @record,
                                               search_term: "Foo")
        expect(rslt[:score]).to eql(0)
      end
      it "adds a weight to each item" do
        rslt = described_class.send(:evaluate, record: @record,
                                               search_term: "Foo")
        expect(rslt[:weight]).to eql(0)
      end
    end

    describe "#score(search_term:, item_name:)" do
      it "returns a high value '99' if term is nil" do
        rslt = described_class.send(:score, search_term: nil,
                                            item_name: "Foo")
        expect(rslt).to eql(99)
      end
      it "returns a high value '99' if item_name is nil" do
        rslt = described_class.send(:score, search_term: "Foo",
                                            item_name: nil)
        expect(rslt).to eql(99)
      end
      it "calls the base class' natuaral language comparison method" do
        Text::Levenshtein.stubs(:distance).returns(0)
        rslt = described_class.send(:score, search_term: "Foo",
                                            item_name: "Bar")
        expect(rslt).to eql(0)
      end
    end

    describe "#weigh(search_term:, item_name:)" do
      before(:each) do
        @term = "Foo"
      end
      it "expects a weight of 3 if the search_term is blank" do
        rslt = described_class.send(:weigh, search_term: nil,
                                            item_name: @term)
        expect(rslt).to eql(3)
      end
      it "expects a weight of 3 if the search_term is blank" do
        rslt = described_class.send(:weigh, search_term: @term,
                                            item_name: nil)
        expect(rslt).to eql(3)
      end
      it "expects a result that starts with the search term to weigh zero" do
        item = "#{@term.downcase}#{Faker::Lorem.sentence}"
        rslt = described_class.send(:weigh, search_term: @term,
                                            item_name: item)
        expect(rslt).to eql(0)
      end
      it "expects a result that contains the search term to weigh one" do
        item = "#{Faker::Lorem.sentence}#{@term.downcase}"
        rslt = described_class.send(:weigh, search_term: @term,
                                            item_name: item)
        expect(rslt).to eql(1)
      end
      it "expects a result that does not contain the search term to weigh two" do
        item = Faker::Lorem.sentence.to_s.gsub(@term, "foo bar")
        rslt = described_class.send(:weigh, search_term: @term,
                                            item_name: item)
        expect(rslt).to eql(2)
      end
    end

    describe "#filter(array:)" do
      it "returns an empty array if the array in is not an Array" do
        expect(described_class.send(:filter, array: nil)).to eql([])
      end
      it "returns all records if they do not have a 'score' and 'weight'" do
        recs = [
          { name: Faker::Lorem.word },
          { name: Faker::Lorem.word }
        ]
        rslts = described_class.send(:filter, array: recs)
        expect(rslts.length).to eql(2)
      end
      it "discards any item whose score is > 25 and weight > 1" do
        recs = [
          { name: Faker::Lorem.word },
          { name: Faker::Lorem.word, score: 26, weight: 2 }
        ]
        rslts = described_class.send(:filter, array: recs)
        expect(rslts.length).to eql(1)
      end
      it "does not discard an item whose weight is > 1 but score < 25" do
        recs = [
          { name: Faker::Lorem.word },
          { name: Faker::Lorem.word, score: 20, weight: 2 }
        ]
        rslts = described_class.send(:filter, array: recs)
        expect(rslts.length).to eql(2)
      end
      it "does not discard an item whose weight is < 2 but score > 25" do
        recs = [
          { name: Faker::Lorem.word },
          { name: Faker::Lorem.word, score: 26, weight: 1 }
        ]
        rslts = described_class.send(:filter, array: recs)
        expect(rslts.length).to eql(2)
      end
    end

  end

end
