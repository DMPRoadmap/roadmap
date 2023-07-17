# frozen_string_literal: true

require 'rails_helper'

require 'ostruct'

RSpec.describe Draft do
  context 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:user) }

    describe 'validates the :metadata' do
      let!(:user) { create(:user, :org_admin) }
      let!(:error_msg) { "Metadata #{Draft::INVALID_JSON_MSG}" }

      it 'is true if metadata structure contains a top level :dmp and at least a :title' do
        draft = build(:draft, user: user, metadata: { dmp: { title: Faker::Music::PearlJam.song } })
        expect(draft.valid?).to be(true)
      end
      it 'is false if there is no top level :dmp' do
        draft = build(:draft, user: user, metadata: { foo: { title: Faker::Music::PearlJam.song } })
        expect(draft.valid?).to be(false)
        expect(draft.errors.full_messages.first).to eql(error_msg)
      end
      it 'is false if the :dmp does not contain a :title' do
        draft = build(:draft, user: user, metadata: { dmp: { description: Faker::Music::PearlJam.song } })
        expect(draft.valid?).to be(false)
        expect(draft.errors.full_messages.first).to eql(error_msg)
      end
    end
  end

  describe 'narrative=(file)' do
    let!(:draft) { create(:draft, user: create(:user)) }

    it 'can be deleted' do
      draft.narrative_content = '12345'
      draft.narrative_file_name = 'foo.pdf'
      draft.narrative = nil

      expect(draft.narrative_content).to be(nil)
      expect(draft.narrative_file_name).to be(nil)
      expect(draft.errors.full_messages.empty?).to be(true)
    end

    it 'adds an error if :file is not a File' do
      draft.narrative = build(:theme)
      expect(draft.narrative_content).to be(nil)
      expect(draft.narrative_file_name).to be(nil)
      expect(draft.errors.full_messages.first).to eql("Narrative #{Draft::INVALID_NARRATIVE_FORMAT}")
    end

    it 'adds an error if :file is not a PDF mime type' do
      file = OpenStruct.new
      file.read = '12345'
      file.content_type = 'application/json'

      draft.narrative = file
      expect(draft.narrative_content).to be(nil)
      expect(draft.narrative_file_name).to be(nil)
      expect(draft.errors.full_messages.first).to eql("Narrative #{Draft::INVALID_NARRATIVE_FORMAT}")
    end

    it 'sets the :narrative_content and :narrative_file_name' do
      file = OpenStruct.new
      file.read = '12345'
      file.content_type = 'application/pdf'
      file.original_filename = 'foo.pdf'

      draft.narrative = file
      expect(draft.narrative_content).to eql('12345')
      expect(draft.narrative_file_name).to eql('foo.pdf')
      expect(draft.errors.full_messages.empty?).to be(true)
    end

    it 'sets the :narrative_content and :narrative_file_name to the draft_id' do
      file = OpenStruct.new
      file.read = '12345'
      file.content_type = 'application/pdf'

      draft.narrative = file
      expect(draft.narrative_content).to eql('12345')
      expect(draft.narrative_file_name).to eql("#{draft.draft_id}.pdf")
      expect(draft.errors.full_messages.empty?).to be(true)
    end
  end

  describe 'to_json' do
    let!(:draft) { create(:draft, user: create(:user), metadata: { dmp: { title: Faker::Music::PearlJam.song } }) }

    it 'adds the :draft_id to the :metadata' do
      json = JSON.parse(draft.to_json)
      expect(json['dmp']['title']).to eql(draft.metadata['dmp']['title'])
      expected = JSON.parse({ type: 'other', draft_id: draft.draft_id }.to_json)
      expect(json['dmp']['draft_id']).to eql(expected)
    end

    it 'adds the :narrative retrieval URL to the :metadata' do
      draft.narrative_content = '12345'
      draft.narrative_file_name = 'foo.pdf'

      related = JSON.parse({ identifier: 'foo', type: 'bar' }.to_json)
      draft.metadata['dmp']['dmproadmap_related_identifiers'] = [related]

      json = JSON.parse(draft.to_json)
      expect(json['dmp']['title']).to eql(draft.metadata['dmp']['title'])
      ids = json['dmp']['dmproadmap_related_identifiers']
      expect(ids.length).to eql(2)
      expect(ids.first).to eql(related)
      expect(ids.last).to eql(draft.send(:narrative_to_related_identifier))
    end
  end

  describe 'generate_draft_id' do
    let!(:user) { create(:user, :org_admin) }

    it 'does not set the :draft_id if it is NOT a new record' do
      draft = create(:draft, user: user)
      before_id = draft.draft_id
      draft.send(:generate_draft_id)
      expect(draft.draft_id).to eql(before_id)
    end

    it 'creates a unique :draft_id' do
      draft = build(:draft, user: user, draft_id: nil)
      draft.send(:generate_draft_id)
      expect(draft.draft_id.nil?).to be(false)
    end
  end

  describe 'remove_draft_id_and_narrative_from_metadata' do
    let!(:draft) { build(:draft, metadata: { dmp: { title: Faker::Music::GratefulDead.song } }) }

    it 'removes the :draft_id' do
      draft.metadata['dmp']['draft_id'] = '12345'
      draft.send(:remove_draft_id_and_narrative_from_metadata)
      expect(draft.metadata['dmp']['title'].nil?).to be(false)
      expect(draft.metadata['dmp']['draft_id']).to be(nil)
    end

    it 'removes the :dmproadmap_related_identifier that represents the :narrative' do
      draft.metadata['dmp']['dmproadmap_related_identifiers'] = JSON.parse([
        { descriptor: 'is_metadata_for', value: 'foo' },
        { descriptor: 'references', value: 'bar' }
      ].to_json)
      draft.send(:remove_draft_id_and_narrative_from_metadata)
      expect(draft.metadata['dmp']['title'].nil?).to be(false)
      expect(draft.metadata['dmp']['dmproadmap_related_identifiers'].length).to eql(1)
      expect(draft.metadata['dmp']['dmproadmap_related_identifiers'].first['value']).to eql('bar')
    end
  end

  describe 'validate_metadata' do
    let!(:user) { create(:user, :org_admin) }

    it 'does not add an error if the :metadata is valid' do
      draft = build(:draft, user: user, metadata: { dmp: { foo: 'bar' } })
      draft.send(:validate_metadata)
      expect(draft.errors.full_messages.length).to eql(1)
      expect(draft.errors.full_messages.first).to eql("Metadata #{Draft::INVALID_JSON_MSG}")
    end

    it 'adds an error if the :metadata is invalid' do
      draft = build(:draft, user: user, metadata: { dmp: { title: 'foo' } })
      draft.send(:validate_metadata)
      expect(draft.errors.empty?).to be(true)
    end
  end

  describe 'narrative_to_related_identifier' do
    let!(:user) { create(:user, :org_admin) }

    it 'returns nil if the draft does not have a narrative defined' do
      draft = create(:draft, user: user, narrative_content: nil, narrative_file_name: nil)
      result = draft.send(:narrative_to_related_identifier)
      expect(result).to be(nil)
    end
    it 'renders the narrative document as a retrieval url' do
      draft = create(:draft, user: user, narrative_content: 'abcdefghijklmnop', narrative_file_name: 'foo.pdf')
      result = draft.send(:narrative_to_related_identifier)
      expect(result['work_type']).to eql('output_management_plan')
      expect(result['descriptor']).to eql('is_metadata_for')
      expect(result['type']).to eql('url')
      expect(result['draft_id']).to eql(Rails.application.routes.url_helpers.narrative_api_v3_draft_url(draft))
    end
  end
end
