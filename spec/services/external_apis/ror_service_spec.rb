# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalApis::RorService do

  describe "#ping" do
    before(:each) do
      @headers = described_class.headers
      @heartbeat = URI("#{described_class.api_base_url}#{described_class.heartbeat_path}")
    end
    it "returns true if an HTTP 200 is returned" do
      stub_request(:get, @heartbeat).with(headers: @headers)
                                    .to_return(status: 200, body: "", headers: {})
      expect(described_class.ping).to eql(true)
    end
    it "returns false if an HTTP 200 is NOT returned" do
      stub_request(:get, @heartbeat).with(headers: @headers)
                                    .to_return(status: 404, body: "", headers: {})
      expect(described_class.ping).to eql(false)
    end
  end

  describe "#search" do
    before(:each) do
      @headers = described_class.headers
      @search = URI("#{described_class.api_base_url}#{described_class.search_path}")
      @heartbeat = URI("#{described_class.api_base_url}#{described_class.heartbeat_path}")
      stub_request(:get, @heartbeat).with(headers: @headers).to_return(status: 200)
    end

    it "returns an empty array if term is blank" do
      expect(described_class.search(term: nil)).to eql([])
    end

    context "ROR did not return a 200 status" do
      before(:each) do
        @term = Faker::Lorem.word
        uri = "#{@search}?page=1&query=#{@term}"
        stub_request(:get, uri).with(headers: @headers)
                               .to_return(status: 404, body: "", headers: {})
      end
      it "returns an empty array" do
        expect(described_class.search(term: @term)).to eql([])
      end
      it "logs the response as an error" do
        described_class.expects(:handle_http_failure).at_least(1)
        described_class.search(term: @term)
      end
    end

    it "returns an empty string if ROR found no matches" do
      results = {
        "number_of_results": 0,
        "time_taken": 23,
        "items": [],
        "meta": { "types": [], "countries" => [] }
      }
      term = Faker::Lorem.word
      uri = "#{@search}?page=1&query=#{term}"
      stub_request(:get, uri).with(headers: @headers)
                             .to_return(status: 200, body: results.to_json, headers: {})
      expect(described_class.search(term: term)).to eql([])
    end

    context "Successful response from API" do
      before(:each) do
        results = {
          "number_of_results": 2,
          "time_taken": 5,
          "items": [
            {
              "id": "https://ror.org/1234567890",
              "name": "Example University",
              "types": ["Education"],
              "links": ["http://example.edu/"],
              "aliases": ["Example"],
              "acronyms": ["EU"],
              "status": "active",
              "country": { "country_name": "United States", "country_code": "US" },
              "external_ids": {
                "GRID": { "preferred": "grid.12345.1", "all": "grid.12345.1" }
              }
            }, {
              "id": "https://ror.org/0987654321",
              "name": "Universidade de Example",
              "types": ["Education"],
              "links": [],
              "aliases": ["Example"],
              "acronyms": ["EU"],
              "status": "active",
              "country": { "country_name": "Mexico", "country_code": "MX" },
              "external_ids": {
                "GRID": { "preferred": "grid.98765.8", "all": "grid.98765.8" }
              }
            }
          ]
        }
        term = Faker::Lorem.word
        uri = "#{@search}?page=1&query=#{term}"
        stub_request(:get, uri).with(headers: @headers)
                               .to_return(status: 200, body: results.to_json, headers: {})
        @orgs = described_class.search(term: term)
      end

      it "returns both results" do
        expect(@orgs.length).to eql(2)
      end

      it "includes the website in the name (if available)" do
        expected = {
          id: "https://ror.org/1234567890",
          name: "Example University (example.edu)"
        }
        expect(@orgs.map { |i| i[:name] }.include?(expected[:name])).to eql(true)
      end

      it "includes the country in the name (if no website is available)" do
        expected = {
          id: "https://ror.org/0987654321",
          name: "Universidade de Example (Mexico)"
        }
        expect(@orgs.map { |i| i[:name] }.include?(expected[:name])).to eql(true)
      end
    end
  end

  context "private methods" do
    describe "#query_ror" do
      before(:each) do
        @results = {
          "number_of_results": 1,
          "time_taken": 5,
          "items": [{
            "id": Faker::Internet.url,
            "name": Faker::Lorem.word,
            "country": { "country_name": Faker::Lorem.word }
          }]
        }
        @term = Faker::Lorem.word
        @headers = described_class.headers
        search = URI("#{described_class.api_base_url}#{described_class.search_path}")
        @uri = "#{search}?page=1&query=#{@term}"
      end

      it "returns an empty array if term is blank" do
        expect(described_class.send(:query_ror, term: nil)).to eql([])
      end
      it "calls the handle_http_failure method if a non 200 response is received" do
        stub_request(:get, @uri).with(headers: @headers)
                                .to_return(status: 403, body: "", headers: {})
        described_class.expects(:handle_http_failure).at_least(1)
        expect(described_class.send(:query_ror, term: @term)).to eql([])
      end
      it "returns the response body as JSON" do
        stub_request(:get, @uri).with(headers: @headers)
                                .to_return(status: 200, body: @results.to_json,
                                           headers: {})
        expect(described_class.send(:query_ror, term: @term)).not_to eql([])
      end
    end

    describe "#query_string" do
      it "assigns the search term to the 'query' argument" do
        str = described_class.send(:query_string, term: "Foo")
        expect(str).to eql("query=Foo&page=1")
      end
      it "defaults the page number to 1" do
        str = described_class.send(:query_string, term: "Foo")
        expect(str).to eql("query=Foo&page=1")
      end
      it "assigns the page number to the 'page' argument" do
        str = described_class.send(:query_string, term: "Foo", page: 3)
        expect(str).to eql("query=Foo&page=3")
      end
      it "ignores empty filter options" do
        str = described_class.send(:query_string, term: "Foo", filters: [])
        expect(str).to eql("query=Foo&page=1")
      end
      it "assigns a single filter" do
        str = described_class.send(:query_string, term: "Foo", filters: ["types:A"])
        expect(str).to eql("query=Foo&page=1&filter=types:A")
      end
      it "assigns multiple filters" do
        str = described_class.send(:query_string, term: "Foo", filters: [
                                     "types:A", "country.country_code:GB"
                                   ])
        expect(str).to eql("query=Foo&page=1&filter=types:A,country.country_code:GB")
      end
    end

    describe "#process_pages" do
      before(:each) do
        described_class.stubs(:max_pages).returns(2)
        described_class.stubs(:max_results_per_page).returns(5)

        @search = URI("#{described_class.api_base_url}#{described_class.search_path}")
        @term = Faker::Lorem.word
        @headers = described_class.headers
      end

      it "returns an empty array if json is blank" do
        rslts = described_class.send(:process_pages, term: @term, json: nil)
        expect(rslts.length).to eql(0)
      end
      it "properly manages results with only one page" do
        items = 4.times.map do
          {
            "id": Faker::Internet.unique.url,
            "name": Faker::Lorem.word,
            "country": { "country_name": Faker::Lorem.word }
          }
        end
        results1 = { "number_of_results": 4, "items": items }

        stub_request(:get, "#{@search}?page=1&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results1.to_json, headers: {})

        json = JSON.parse({ "items": items, "number_of_results": 4 }.to_json)
        rslts = described_class.send(:process_pages, term: @term, json: json)

        expect(rslts.length).to eql(4)
      end
      it "properly manages results with multiple pages" do
        items = 7.times.map do
          {
            "id": Faker::Internet.unique.url,
            "name": Faker::Lorem.word,
            "country": { "country_name": Faker::Lorem.word }
          }
        end
        results1 = { "number_of_results": 7, "items": items[0..4] }
        results2 = { "number_of_results": 7, "items": items[5..6] }

        stub_request(:get, "#{@search}?page=1&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results1.to_json, headers: {})
        stub_request(:get, "#{@search}?page=2&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results2.to_json, headers: {})

        json = JSON.parse({ "items": items[0..4], "number_of_results": 7 }.to_json)
        rslts = described_class.send(:process_pages, term: @term, json: json)
        expect(rslts.length).to eql(7)
      end
      it "does not go beyond the max_pages" do
        items = 12.times.map do
          {
            "id": Faker::Internet.unique.url,
            "name": Faker::Lorem.word,
            "country": { "country_name": Faker::Lorem.word }
          }
        end
        results1 = { "number_of_results": 12, "items": items[0..4] }
        results2 = { "number_of_results": 12, "items": items[5..9] }

        stub_request(:get, "#{@search}?page=1&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results1.to_json, headers: {})
        stub_request(:get, "#{@search}?page=2&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results2.to_json, headers: {})

        json = JSON.parse({ "items": items[0..4], "number_of_results": 12 }.to_json)
        rslts = described_class.send(:process_pages, term: @term, json: json)
        expect(rslts.length).to eql(10)
      end
    end

    describe "#parse_results" do
      it "returns an empty array if there are no items" do
        expect(described_class.send(:parse_results, json: nil)).to eql([])
      end
      it "ignores items with no name or id" do
        json = { "items": [
          { "id": Faker::Internet.url, "name": Faker::Lorem.word },
          { "id": Faker::Internet.url },
          { "name": Faker::Lorem.word }
        ] }.to_json
        items = described_class.send(:parse_results, json: JSON.parse(json))
        expect(items.length).to eql(1)
      end
      it "returns the correct number of results" do
        json = { "items": [
          { "id": Faker::Internet.url, "name": Faker::Lorem.word },
          { "id": Faker::Internet.url, "name": Faker::Lorem.word }
        ] }.to_json
        items = described_class.send(:parse_results, json: JSON.parse(json))
        expect(items.length).to eql(2)
      end
    end

    describe "#org_name" do
      it "returns nil if there is no name" do
        json = { "country": { "country_name": "Nowhere" } }.to_json
        expect(described_class.send(:org_name, item: JSON.parse(json))).to eql("")
      end
      it "properly appends the website if available" do
        json = {
          "name": "Example College",
          "links": ["https://example.edu"],
          "country": { "country_name": "Nowhere" }
        }.to_json
        expected = "Example College (example.edu)"
        expect(described_class.send(:org_name, item: JSON.parse(json))).to eql(expected)
      end
      it "properly appends the country if available and no website is available" do
        json = {
          "name": "Example College",
          "country": { "country_name": "Nowhere" }
        }.to_json
        expected = "Example College (Nowhere)"
        expect(described_class.send(:org_name, item: JSON.parse(json))).to eql(expected)
      end
      it "properly handles an item with no website or country" do
        json = {
          "name": "Example College",
          "links": [],
          "country": {}
        }.to_json
        expected = "Example College"
        expect(described_class.send(:org_name, item: JSON.parse(json))).to eql(expected)
      end
    end

    describe "#org_website" do
      it "returns nil if no 'links' are in the json" do
        item = JSON.parse({ "links": nil }.to_json)
        expect(described_class.send(:org_website, item: item)).to eql(nil)
      end
      it "returns nil if the item is nil" do
        expect(described_class.send(:org_website, item: nil)).to eql(nil)
      end
      it "returns the domain only" do
        item = JSON.parse({ "links": ["https://example.org/path?a=b"] }.to_json)
        expect(described_class.send(:org_website, item: item)).to eql("example.org")
      end
      it "removes the www prefix" do
        item = JSON.parse({ "links": ["www.example.org"] }.to_json)
        expect(described_class.send(:org_website, item: item)).to eql("example.org")
      end
    end

    describe "#fundref_id" do
      before(:each) do
        @hash = { "external_ids": {} }
      end
      it "returns a blank if no external_ids are present" do
        json = JSON.parse(@hash.to_json)
        expect(described_class.send(:fundref_id, item: json)).to eql("")
      end
      it "returns a blank if no FundRef ids are present" do
        @hash["external_ids"] = { "FundRef": {} }
        json = JSON.parse(@hash.to_json)
        expect(described_class.send(:fundref_id, item: json)).to eql("")
      end
      it "returns the preferred id when specified" do
        @hash["external_ids"] = { "FundRef": { "preferred": "1", "all": %w[2 1] } }
        json = JSON.parse(@hash.to_json)
        expect(described_class.send(:fundref_id, item: json)).to eql("1")
      end
      it "returns the firstid if no preferred is specified" do
        @hash["external_ids"] = { "FundRef": { "preferred": nil, "all": %w[2 1] } }
        json = JSON.parse(@hash.to_json)
        expect(described_class.send(:fundref_id, item: json)).to eql("2")
      end
    end

  end
end
