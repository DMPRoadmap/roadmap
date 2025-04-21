# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::SpdxService do
  include Webmocks

  before(:each) do
    License.all.destroy_all

    @licenses_results = {
      reference: "./#{Faker::Lorem.unique.word}.html",
      isDeprecatedLicenseId: [true, false].sample,
      detailsUrl: Faker::Internet.unique.url,
      referenceNumber: Faker::Number.unique.number(digits: 2),
      name: Faker::Music::PearlJam.unique.album,
      licenseId: Faker::Music::PearlJam.unique.song.upcase.gsub(/\s/, '_'),
      seeAlso: [
        Faker::Internet.unique.url
      ],
      isOsiApproved: [true, false].sample
    }

    stub_spdx_service(successful: true, response_body: { licenses: @licenses_results }.to_json)
  end

  describe ':fetch' do
    it 'returns an empty array if spdx did not return a repository list' do
      described_class.expects(:query_spdx).returns(nil)
      expect(described_class.fetch).to eql([])
    end
    it 'fetches the licenses' do
      described_class.expects(:query_spdx).returns({ licenses: @licenses_results })
      described_class.expects(:process_license).returns(true)
      described_class.fetch
    end
  end

  context 'private methods' do
    describe ':query_spdx' do
      it 'calls the error handler if an HTTP 200 is not received from the SPDX API' do
        stub_spdx_service(successful: false)
        described_class.expects(:handle_http_failure)
        expect(described_class.send(:query_spdx)).to eql([])
      end
      it 'logs an error if the response was invalid JSON' do
        JSON.expects(:parse).raises(JSON::ParserError.new)
        described_class.expects(:log_error)
        expect(described_class.send(:query_spdx)).to eql([])
      end
      it 'returns an empty array if the response contains no license' do
        JSON.expects(:parse).returns({})
        expect(described_class.send(:query_spdx)).to eql([])
      end
      it 'reuturns the array of licenses' do
        expect(described_class.send(:query_spdx)).to eql(JSON.parse(@licenses_results.to_json))
      end
    end

    describe ':process_license(hash:)' do
      it 'returns nil if hash is empty' do
        expect(described_class.send(:process_license, hash: nil)).to eql(nil)
      end

      it 'returns nil if a License could not be initialized' do
        License.expects(:find_or_initialize_by).returns(nil)
        expect(described_class.send(:process_license, hash: @licenses_results)).to eql(nil)
      end

      it 'updates existing License records' do
        hash = @licenses_results
        license = create(:license, identifier: hash[:licenseId])

        expect(described_class.send(:process_license, hash: JSON.parse(hash.to_json)))
        result = License.last
        expect(result.id).to eql(license.id)
        expect(result.name).to eql(hash[:name])
        expect(result.uri).to eql(hash[:detailsUrl])
        expect(result.osi_approved).to eql(hash[:isOsiApproved])
        expect(result.deprecated).to eql(hash[:isDeprecatedLicenseId])
      end

      it 'creates new License records' do
        hash = @licenses_results

        expect(described_class.send(:process_license, hash: JSON.parse(hash.to_json)))
        result = License.last
        expect(result.identifier).to eql(hash[:licenseId])
        expect(result.name).to eql(hash[:name])
        expect(result.uri).to eql(hash[:detailsUrl])
        expect(result.osi_approved).to eql(hash[:isOsiApproved])
        expect(result.deprecated).to eql(hash[:isDeprecatedLicenseId])
      end
    end
  end
end
