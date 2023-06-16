# frozen_string_literal: true

require 'rails_helper'

require 'ostruct'

RSpec.describe Wip do
  context 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:user) }

    describe 'validates the :metadata' do
      let!(:user) { create(:user, :org_admin) }
      let!(:error_msg) { "Metadata #{Wip::INVALID_JSON_MSG}" }

      it 'is true if metadata structure contains a top level :dmp and at least a :title' do
        wip = build(:wip, user: user, metadata: { dmp: { title: Faker::Music::PearlJam.song } })
        expect(wip.valid?).to be(true)
      end
      it 'is false if there is no top level :dmp' do
        wip = build(:wip, user: user, metadata: { foo: { title: Faker::Music::PearlJam.song } })
        expect(wip.valid?).to be(false)
        expect(wip.errors.full_messages.first).to eql(error_msg)
      end
      it 'is false if the :dmp does not contain a :title' do
        wip = build(:wip, user: user, metadata: { dmp: { description: Faker::Music::PearlJam.song } })
        expect(wip.valid?).to be(false)
        expect(wip.errors.full_messages.first).to eql(error_msg)
      end
    end
  end

  describe 'narrative=(file)' do
    let!(:wip) { create(:wip, user: create(:user)) }

    it 'can be deleted' do
      wip.narrative_content = '12345'
      wip.narrative_file_name = 'foo.pdf'
      wip.narrative = nil

      expect(wip.narrative_content).to be(nil)
      expect(wip.narrative_file_name).to be(nil)
      expect(wip.errors.full_messages.empty?).to be(true)
    end

    it 'adds an error if :file is not a File' do
      wip.narrative = build(:theme)
      expect(wip.narrative_content).to be(nil)
      expect(wip.narrative_file_name).to be(nil)
      expect(wip.errors.full_messages.first).to eql("Narrative #{Wip::INVALID_NARRATIVE_FORMAT}")
    end

    it 'adds an error if :file is not a PDF mime type' do
      file = OpenStruct.new
      file.read = '12345'
      file.content_type = 'application/json'

      wip.narrative = file
      expect(wip.narrative_content).to be(nil)
      expect(wip.narrative_file_name).to be(nil)
      expect(wip.errors.full_messages.first).to eql("Narrative #{Wip::INVALID_NARRATIVE_FORMAT}")
    end

    it 'sets the :narrative_content and :narrative_file_name' do
      file = OpenStruct.new
      file.read = '12345'
      file.content_type = 'application/pdf'
      file.original_filename = 'foo.pdf'

      wip.narrative = file
      expect(wip.narrative_content).to eql('12345')
      expect(wip.narrative_file_name).to eql('foo.pdf')
      expect(wip.errors.full_messages.empty?).to be(true)
    end

    it 'sets the :narrative_content and :narrative_file_name to the identifier' do
      file = OpenStruct.new
      file.read = '12345'
      file.content_type = 'application/pdf'

      wip.narrative = file
      expect(wip.narrative_content).to eql('12345')
      expect(wip.narrative_file_name).to eql("#{wip.identifier}.pdf")
      expect(wip.errors.full_messages.empty?).to be(true)
    end
  end

  describe 'to_json' do
    let!(:wip) { create(:wip, user: create(:user), metadata: { dmp: { title: Faker::Music::PearlJam.song } }) }

    it 'adds the :wip_id to the :metadata' do
      json = JSON.parse(wip.to_json)
      expect(json['dmp']['title']).to eql(wip.metadata['dmp']['title'])
      expected = JSON.parse({ type: 'other', identifier: wip.identifier }.to_json)
      expect(json['dmp']['wip_id']).to eql(expected)
    end

    it 'adds the :narrative retrieval URL to the :metadata' do
      wip.narrative_content = '12345'
      wip.narrative_file_name = 'foo.pdf'

      related = JSON.parse({ identifier: 'foo', type: 'bar' }.to_json)
      wip.metadata['dmp']['dmproadmap_related_identifiers'] = [related]

      json = JSON.parse(wip.to_json)
      expect(json['dmp']['title']).to eql(wip.metadata['dmp']['title'])
      ids = json['dmp']['dmproadmap_related_identifiers']
      expect(ids.length).to eql(2)
      expect(ids.first).to eql(related)
      expect(ids.last).to eql(wip.send(:narrative_to_related_identifier))
    end
  end

  describe 'generate_identifier' do
    let!(:user) { create(:user, :org_admin) }

    it 'does not set the :identifier if it is NOT a new record' do
      wip = create(:wip, user: user)
      before_id = wip.identifier
      wip.send(:generate_identifier)
      expect(wip.identifier).to eql(before_id)
    end

    it 'creates a unique :identifier' do
      wip = build(:wip, user: user, identifier: nil)
      wip.send(:generate_identifier)
      expect(wip.identifier.nil?).to be(false)
    end
  end

  describe 'remove_wip_id_and_narrative_from_metadata' do
    let!(:wip) { build(:wip, metadata: { dmp: { title: Faker::Music::GratefulDead.song } }) }

    it 'removes the :wip_id' do
      wip.metadata['dmp']['wip_id'] = '12345'
      wip.send(:remove_wip_id_and_narrative_from_metadata)
      expect(wip.metadata['dmp']['title'].nil?).to be(false)
      expect(wip.metadata['dmp']['wip_id']).to be(nil)
    end

    it 'removes the :dmproadmap_related_identifier that represents the :narrative' do
      wip.metadata['dmp']['dmproadmap_related_identifiers'] = JSON.parse([
        { descriptor: 'is_metadata_for', value: 'foo' },
        { descriptor: 'references', value: 'bar' }
      ].to_json)
      wip.send(:remove_wip_id_and_narrative_from_metadata)
      expect(wip.metadata['dmp']['title'].nil?).to be(false)
      expect(wip.metadata['dmp']['dmproadmap_related_identifiers'].length).to eql(1)
      expect(wip.metadata['dmp']['dmproadmap_related_identifiers'].first['value']).to eql('bar')
    end
  end

  describe 'validate_metadata' do
    let!(:user) { create(:user, :org_admin) }

    it 'does not add an error if the :metadata is valid' do
      wip = build(:wip, user: user, metadata: { dmp: { foo: 'bar' } })
      wip.send(:validate_metadata)
      expect(wip.errors.full_messages.length).to eql(1)
      expect(wip.errors.full_messages.first).to eql("Metadata #{Wip::INVALID_JSON_MSG}")
    end

    it 'adds an error if the :metadata is invalid' do
      wip = build(:wip, user: user, metadata: { dmp: { title: 'foo' } })
      wip.send(:validate_metadata)
      expect(wip.errors.empty?).to be(true)
    end
  end

  describe 'narrative_to_related_identifier' do
    let!(:user) { create(:user, :org_admin) }

    it 'returns nil if the wip does not have a narrative defined' do
      wip = create(:wip, user: user, narrative_content: nil, narrative_file_name: nil)
      result = wip.send(:narrative_to_related_identifier)
      expect(result).to be(nil)
    end
    it 'renders the narrative document as a retrieval url' do
      wip = create(:wip, user: user, narrative_content: 'abcdefghijklmnop', narrative_file_name: 'foo.pdf')
      result = wip.send(:narrative_to_related_identifier)
      expect(result['work_type']).to eql('output_management_plan')
      expect(result['descriptor']).to eql('is_metadata_for')
      expect(result['type']).to eql('url')
      expect(result['identifier']).to eql(Rails.application.routes.url_helpers.narrative_api_v3_wip_url(wip))
    end
  end
end
