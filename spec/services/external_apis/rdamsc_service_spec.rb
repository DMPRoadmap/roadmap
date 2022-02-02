# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::RdamscService do
  include Webmocks

  before(:each) do
    MetadataStandard.all.destroy_all

    @rdams_results = {
      apiVersion: '2.0.0',
      data: {
        currentItemCount: Faker::Number.number(digits: 2),
        items: [
          {
            description: Faker::Lorem.paragraph,
            keywords: [
              Faker::Internet.unique.url
            ],
            locations: [
              { type: %w[document website].sample, url: Faker::Internet.unique.url }
            ],
            mscid: "msc:m#{Faker::Number.number(digits: 2)}",
            relatedEntities: [
              { id: "msc:m#{Faker::Number.number(digits: 2)}", role: %w[scheme child].sample }
            ],
            slug: SecureRandom.uuid,
            title: Faker::Lorem.sentence,
            uri: Faker::Internet.unique.url
          }
        ]
      }
    }

    stub_rdamsc_service(successful: true, response_body: @rdams_results.to_json)
  end

  describe ':fetch_metadata_standards' do
    it 'calls :query_schemes' do
      described_class.expects(:query_schemes).returns(nil)
      expect(described_class.fetch_metadata_standards).to eql(nil)
    end
  end

  context 'private methods' do
    describe ':query_api(path:)' do
      it 'returns nil if path is not present' do
        expect(described_class.send(:query_api, path: nil)).to eql(nil)
      end
      it 'calls the error handler if an HTTP 200 is not received from the SPDX API' do
        stub_rdamsc_service(successful: false)
        described_class.expects(:handle_http_failure)
        expect(described_class.send(:query_api, path: Faker::Lorem.word)).to eql(nil)
      end
      it 'logs an error if the response was invalid JSON' do
        JSON.expects(:parse).raises(JSON::ParserError.new)
        described_class.expects(:log_error)
        expect(described_class.send(:query_api, path: Faker::Lorem.word)).to eql(nil)
      end
      it 'reuturns the array of response body as JSON' do
        expected = JSON.parse(@rdams_results.to_json)
        expect(described_class.send(:query_api, path: Faker::Lorem.word)).to eql(expected)
      end
    end

    describe ':query_schemes(path:)' do
      before(:each) do
        @path = Faker::Internet.unique.url
      end
      it 'returns false if the initial query returned no results' do
        described_class.expects(:query_api).with(path: @path).returns(nil)
        expect(described_class.send(:query_schemes, path: @path)).to eql(false)
      end
      it 'calls :process_scheme_entries if the query returned results' do
        described_class.expects(:query_api).with(path: @path).returns(@rdams_results)
        described_class.expects(:process_scheme_entries)
        described_class.send(:query_schemes, path: @path)
      end
      it "recursively calls itself while a 'nextLink' is provided in the query results" do
        hash = @rdams_results
        hash[:data][:nextLink] = "#{@path}/next"
        described_class.expects(:query_api)
                       .with(path: @path).returns(hash.with_indifferent_access)
        described_class.expects(:query_api)
                       .with(path: hash[:data][:nextLink]).returns(@rdams_results)
        described_class.expects(:process_scheme_entries).twice
        described_class.send(:query_schemes, path: @path)
      end
    end

    describe ':process_scheme_entries(json:)' do
      it 'returns false if json is not present' do
        expect(described_class.send(:process_scheme_entries, json: nil)).to eql(false)
      end
      it 'returns false if json does not contain :data not present' do
        expect(described_class.send(:process_scheme_entries, json: { foo: 'bar' })).to eql(false)
      end
      it 'returns false if json[:data] does not contain :items present' do
        json = { data: { items: [] } }
        expect(described_class.send(:process_scheme_entries, json: json)).to eql(false)
      end
      it 'updates the MetadataStandard if it already exists' do
        hash = @rdams_results[:data][:items].first
        standard = create(:metadata_standard, uri: hash[:uri],
                                              title: hash[:title])

        expect(described_class.send(:process_scheme_entries,
                                    json: JSON.parse(@rdams_results.to_json)))
        result = MetadataStandard.last
        expect(result.id).to eql(standard.id)
        expect(result.title).to eql(hash[:title])
        expect(result.uri).to eql(hash[:uri])

        expect(result.description).to eql(hash[:description])
        expect(result.rdamsc_id).to eql(hash[:mscid])
        expect(result.locations).to eql(JSON.parse(hash[:locations].to_json))
        expect(result.related_entities).to eql(JSON.parse(hash[:relatedEntities].to_json))
      end
      it 'creates a new MetadataStandard' do
        hash = @rdams_results[:data][:items].first

        expect(described_class.send(:process_scheme_entries,
                                    json: JSON.parse(@rdams_results.to_json)))
        result = MetadataStandard.last
        expect(result.title).to eql(hash[:title])
        expect(result.description).to eql(hash[:description])
        expect(result.rdamsc_id).to eql(hash[:mscid])
        expect(result.uri).to eql(hash[:uri])
        expect(result.locations).to eql(JSON.parse(hash[:locations].to_json))
        expect(result.related_entities).to eql(JSON.parse(hash[:relatedEntities].to_json))
      end
    end
  end
end
