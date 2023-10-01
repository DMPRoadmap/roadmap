# frozen_string_literal: true

require 'rails_helper'

require 'ostruct'

RSpec.describe Draft do
  include Helpers::IdentifierHelper

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

  describe 'self.search(user:, params: {})' do
    let!(:user) { create(:user) }

    let!(:draft1) do
      create(:draft, user: user, metadata: { dmp: {
        title: 'Foo bar',
        description: 'Foo lorem ipsum',
        project: [
          funding: [{ name: 'Government', grant_id: { type: 'other', identifier: '12345' } }]
        ],
        dmproadmap_privacy: 'public'
      }})
    end
    let!(:draft2) do
      create(:draft, user: user, metadata: { dmp: {
        title: 'Foo baZ',
        description: 'Lorem ipsum bar',
        project: [
          funding: [{ name: 'Institution', grant_id: { type: 'other', identifier: '98765' } }]
        ],
        dmproadmap_privacy: 'private'
      }})
    end
    let!(:draft3) do
      create(:draft, user: user, dmp_id: 'https://doi.org/10.12345/A1B2C3P0', metadata: { dmp: {
        title: 'Bar',
        dmp_id: { type: 'doi', identifier: 'https://doi.org/10.12345/A1B2C3P0' },
        draft_data: { is_private: true }
      }})
    end
    let!(:draft4) do
      create(:draft, user: create(:user), dmp_id: 'https://doi.org/10.12345/Z9Y8R2D2', metadata: { dmp: {
        title: 'Foo Not mine',
        dmp_id: { type: 'doi', identifier: 'https://doi.org/10.12345/Z9Y8R2D2' },
        dmproadmap_privacy: 'public'
      }})
    end

    it 'returns an empty Array if :user is not a User' do
      results = described_class.search(user: 123, params: { title: 'FOO' })
      expect(results.length).to eql(0)
    end
    it 'handles a title search' do
      results = described_class.search(user: user, params: { title: 'FOO' })
      expect(results.length).to eql(2)
      expect(results.include?(draft1)).to be(true)
      expect(results.include?(draft2)).to be(true)
    end
    it 'handles an abstract search' do
      results = described_class.search(user: user, params: { title: 'LOREM' })
      expect(results.length).to eql(2)
      expect(results.include?(draft1)).to be(true)
      expect(results.include?(draft2)).to be(true)
    end
    it 'handles a funder name search' do
      results = described_class.search(user: user, params: { funder: 'Institution' })
      expect(results.length).to eql(1)
      expect(results.include?(draft2)).to be(true)
    end
    it 'handles a grant id search' do
      results = described_class.search(user: user, params: { grant_id: '12345' })
      expect(results.length).to eql(1)
      expect(results.include?(draft1)).to be(true)
    end
    it 'handles a visibility filter for public' do
      results = described_class.search(user: user, params: { visibility: 'public' })
      expect(results.length).to eql(1)
      expect(results.include?(draft1)).to be(true)
    end
    it 'handles a visibility filter for private' do
      results = described_class.search(user: user, params: { visibility: 'private' })
      expect(results.length).to eql(2)
      expect(results.include?(draft2)).to be(true)
      expect(results.include?(draft3)).to be(true)
    end
    it 'handles a DMP ID search for the full DOI' do
      results = described_class.search(user: user, params: { dmp_id: 'https://doi.org/10.12345/A1B2C3P0' })
      expect(results.length).to eql(1)
      expect(results.include?(draft3)).to be(true)
    end
    it 'handles a DMP ID search for the partial DOI' do
      results = described_class.search(user: user, params: { dmp_id: '10.12345/A1B2C3P0' })
      expect(results.length).to eql(1)
      expect(results.include?(draft3)).to be(true)
    end
    it 'handles all at once' do
      # search for 'BAR' alone will return 3 results, adding a Funder reduces it to 1
      results = described_class.search(user: user, params: { title: 'BAR' })
      expect(results.length).to eql(3)
      expect(results.include?(draft1)).to be(true)
      expect(results.include?(draft2)).to be(true)
      expect(results.include?(draft3)).to be(true)

      results = described_class.search(user: user, params: { title: 'BAR', funder: 'Institution' } )
      expect(results.length).to eql(1)
      expect(results.include?(draft2)).to be(true)
    end
    it 'does not return other user drafts!' do
      results = described_class.search(user: user, params: { dmp_id: 'https://doi.org/10.12345/Z9Y8R2D2' })
      expect(results.length).to eql(0)
    end
  end

  describe 'registerable?' do
    let!(:user) { create(:user) }
    let!(:draft) do
      d = create(:draft, user: user)
      d.metadata['dmp']['contact'] = JSON.parse(
        { name: 'foo', mbox: 'foo@bar.org', contact_id: { type: 'a', identifier: 'b' } }.to_json
      )
      d
    end

    it 'returns true if the Draft already has a :dmp_id' do
      draft.dmp_id = 'https://doi.org/10.12345/ABCD'
      expect(draft.registerable?).to be(true)
    end
    it 'returns false if the Draft does not have a :draft_id' do
      draft.draft_id = nil
      expect(draft.registerable?).to be(false)
    end
    it 'returns false if the Draft does not have a :user' do
      draft.user = nil
      expect(draft.registerable?).to be(false)
    end
    it 'returns false if the Draft :metadata does not have a :title' do
      draft.metadata['dmp'].delete('title')
      expect(draft.registerable?).to be(false)
    end
    it 'returns false if the Draft :metadata does not have a :contact with a :name' do
      draft.metadata['dmp']['contact'].delete('name')
      expect(draft.registerable?).to be(false)
    end
    it 'returns false if the Draft :metadata does not have a :contact with a :mbox' do
      draft.metadata['dmp']['contact'].delete('mbox')
      expect(draft.registerable?).to be(false)
    end
    it 'returns false if the Draft :metadata does not have a :contact with a :contact_id' do
      draft.metadata['dmp']['contact'].delete('contact_id')
      expect(draft.registerable?).to be(false)
    end
    it 'returns false if the Draft :metadata does not have a :contact with a contact_id:type' do
      draft.metadata['dmp']['contact']['contact_id'].delete('type')
      expect(draft.registerable?).to be(false)
    end
    it 'returns false if the Draft :metadata does not have a :contact with a contact_id:type' do
      draft.metadata['dmp']['contact']['contact_id'].delete('identifier')
      expect(draft.registerable?).to be(false)
    end
    it 'returns true if the Draft has a :draft_id and the :metadata has a :title and valid :contact' do
      expect(draft.registerable?).to be(true)
    end
  end

  describe 'to_json' do
    let!(:draft) { create(:draft, user: create(:user), metadata: { dmp: { title: Faker::Music::PearlJam.song } }) }

    it 'adds the :draft_id to the :metadata' do
      json = JSON.parse(draft.to_json)
      expect(json['dmp']['title']).to eql(draft.metadata['dmp']['title'])
      expected = JSON.parse({ type: 'other', identifier: draft.draft_id }.to_json)
      expect(json['dmp']['draft_id']).to eql(expected)
    end

    it 'adds the :narrative retrieval URL to the :metadata' do
      draft.narrative.attach(
        io: File.open(Rails.root.join('spec', 'support', 'mocks', 'narrative_test.pdf')),
        filename: 'narrative_test.pdf', content_type: "application/pdf")
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

  describe 'to_json_for_registration' do
    let!(:user) { create(:user) }
    let!(:draft) do
      d = create(:draft, user: user)
      d.metadata['dmp']['draft_data'] = JSON.parse({ foo: 'bar' }.to_json)
      d.metadata['dmp']['contributor'] = JSON.parse([
        { name: 'Foo Bar', contact: false }, { name: 'Foo Bar', contact: true }
      ].to_json)
      d.metadata['dmp'].delete('contact')
      d.metadata['dmp'].delete('dataset')
      d.metadata['dmp'].delete('dmproadmap_privacy')
      d.metadata['dmp'].delete('project')
      d
    end

    it 'removes any :draft_data' do
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['draft_data']).to be(nil)
    end
    it 'calls :designate_contact if no :contact is defined' do
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['contact']['name'].present?).to be(true)
    end
    it 'removes the :contact flag from the :contributor entries' do
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['contributor'][0]['contact']).to be(nil)
      expect(result['dmp']['contributor'][1]['contact']).to be(nil)
    end
    it 'adds the :dmp_id if the Draft is already registered' do
      draft.dmp_id = 'FOOOOO'
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['dmp_id'].present?).to be(true)
      expect(result['dmp']['dmp_id']['type']).to eql('doi')
      expect(result['dmp']['dmp_id']['identifier']).to eql(draft.dmp_id)
    end
    it 'adds the :dmp_id as the API URL if the Draft is not registered' do
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['dmp_id'].present?).to be(true)
      expect(result['dmp']['dmp_id']['type']).to eql('url')
      expect(result['dmp']['dmp_id']['identifier']).to eql(Rails.application.routes.url_helpers.api_v3_url(draft))
    end
    it 'adds :dataset as an empty array if none is defined' do
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['dataset']).to eql([])
    end
    it 'adds :project as an empty array if none is defined' do
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['project']).to eql([])
    end
    it 'sets the :dmproadmap_privacy to private if it is not defined' do
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['dmproadmap_privacy']).to eql('private')
    end
    it 'calls :ensure_defaults' do
      draft.metadata['dmp']['contributor'][0]['contributor_id'] = JSON.parse({ identifier: 'ABCD' }.to_json)
      result = JSON.parse(draft.to_json_for_registration)
      expect(result['dmp']['contributor'][0]['contributor_id']['type']).to eql('orcid')
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

  describe 'generate_timestamps' do
    let!(:user) { create(:user, :org_admin) }
    let!(:draft) { build(:draft, user: user) }

    it 'returns false if :metadata is nil' do
      draft.metadata = nil
      expect(draft.send(:generate_timestamps)).to be(false)
    end
    it 'returns false if :metadata does not contain :dmp' do
      draft.metadata = JSON.parse({ foo: 'bar' }.to_json)
      expect(draft.send(:generate_timestamps)).to be(false)
    end
    it 'if :metadata contains :created it leaves it alone' do
      draft.metadata['dmp']['created'] = 'foo'
      expect(draft.send(:generate_timestamps)).to be(true)
      expect(draft.metadata['dmp']['created']).to eql('foo')
    end
    it 'if :metadata contains :modified it leaves it alone' do
      draft.metadata['dmp']['modified'] = 'foo'
      expect(draft.send(:generate_timestamps)).to be(true)
      expect(draft.metadata['dmp']['modified']).to eql('foo')
    end

    context 'new record' do
      let!(:time) { Time.now.to_formatted_s(:iso8601) }
      it 'if :metadata does not contain :created it sets it to the :created_at timestamp' do
        expect(draft.send(:generate_timestamps)).to be(true)
        expect(draft.metadata['dmp']['created'] >= time).to be(true)
      end
      it 'if :metadata does not contain :modified it sets it to the :updated_at timestamp' do
        expect(draft.send(:generate_timestamps)).to be(true)
        expect(draft.metadata['dmp']['created'] == draft.metadata['dmp']['modified']).to be(true)
      end
    end

    context 'existing record' do
      it 'if :metadata does not contain :created it sets it to the :created_at timestamp' do
        draft.save
        expect(draft.send(:generate_timestamps)).to be(true)
        expect(draft.metadata['dmp']['created']).to eql(draft.created_at.to_formatted_s(:iso8601))
      end
      it 'if :metadata does not contain :modified it sets it to the :updated_at timestamp' do
        draft.save
        expect(draft.send(:generate_timestamps)).to be(true)
        expect(draft.metadata['dmp']['modified']).to eql(draft.updated_at.to_formatted_s(:iso8601))
      end
    end
  end

  describe 'append_ror_ids' do
    let!(:user) { create(:user, :org_admin) }
    let!(:org) { create(:registry_org) }
    let!(:expected) { JSON.parse({ type: 'ror', identifier: org.ror_id }.to_json) }

    let!(:draft) do
      d = create(:draft, user: user)
      d.metadata['dmp']['contact'] = JSON.parse({ name: 'contact', dmproadmap_affiliation: { name: org.name } }.to_json)
      d.metadata['dmp']['contributor'] = JSON.parse([
        { name: 'contributor1', dmproadmap_affiliation: { name: org.name } }, { name: 'contributor2' }
      ].to_json)
      d.metadata['dmp']['project'] = JSON.parse([
        { funding: [{ name: org.name }, { foo: 'bar' }] }, { title: 'bar' }
      ].to_json)
      d
    end

    it 'skips new records' do
      draft = build(:draft)
      draft.send(:append_ror_ids)
      expect(draft.metadata['dmp']['contact']).to be(nil)
    end
    it 'appends the ROR id for :contributor entries in :metadata' do
      draft.send(:append_ror_ids)
      expect(draft.metadata['dmp']['contact']['dmproadmap_affiliation']['affiliation_id']).to eql(expected)
    end
    it 'appends the ROR id for the :contributor in :metadata' do
      draft.send(:append_ror_ids)
      expect(draft.metadata['dmp']['contributor'][0]['dmproadmap_affiliation']['affiliation_id']).to eql(expected)
      expect(draft.metadata['dmp']['contributor'][1]['dmproadmap_affiliation']).to be(nil)
    end
    it 'appends the ROR id for :funding entries in :metadata' do
      draft.send(:append_ror_ids)
      expect(draft.metadata['dmp']['project'][0]['funding'][0]['funder_id']).to eql(expected)
      expect(draft.metadata['dmp']['project'][0]['funding'][1]['funder_id']).to be(nil)
      expect(draft.metadata['dmp']['project'][1]['funding']).to be(nil)
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
      draft = create(:draft, user: user)
      result = draft.send(:narrative_to_related_identifier)
      expect(result).to be(nil)
    end
    it 'renders the narrative document as a retrieval url' do
      draft = create(:draft, user: user)
      draft.narrative.attach(
        io: File.open(Rails.root.join('spec', 'support', 'mocks', 'logo_file.png')),
        filename: 'logo_file.png', content_type: "image/png")
      result = draft.send(:narrative_to_related_identifier)
      expect(result['work_type']).to eql('output_management_plan')
      expect(result['descriptor']).to eql('is_metadata_for')
      expect(result['type']).to eql('url')
      expected = Rails.application.routes.url_helpers.rails_blob_url(draft.narrative, disposition: 'attachment')
      expect(result['identifier']).to eql(expected)
    end
  end

  describe 'ensure_defaults(dmp:)' do
    let!(:user) { create(:user, :org_admin) }
    let!(:draft) { create(:draft, user: user) }
    let!(:dmp) { JSON.parse({ title: 'Foo', contributor: [], project: [] }.to_json) }

    it 'returns an empty Hash if :dmp is not a Hash' do
      expect(draft.send(:ensure_defaults, dmp: [])).to eql({})
    end
    it 'removes blank :contributor_id' do
      dmp['contributor'] = JSON.parse([{ name: 'Foo', contributor_id: { type: 'blah', identifier: '' } }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['contributor'][0]['contributor_id']).to be(nil)
    end
    it 'adds the :type to :contributor_id if it is missing' do
      dmp['contributor'] = JSON.parse([{ name: 'Foo', contributor_id: { identifier: '123' } }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['contributor'][0]['contributor_id']['type']).to eql('orcid')
    end
    it 'leaves the :type on the :contributor_id alone if it is present' do
      dmp['contributor'] = JSON.parse([{ name: 'Foo', contributor_id: { type: 'blah', identifier: '123' } }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['contributor'][0]['contributor_id']['type']).to eql('blah')
    end
    it 'deletes blank :funding :name' do
      dmp['project'] = JSON.parse([{ funding: [{ name: '' }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['project'][0]['funding'][0]['name']).to be(nil)
    end
    it 'sets the :funding_status to planned if there is no grant_id' do
      dmp['project'] = JSON.parse([{ funding: [{ name: 'Foo' }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['project'][0]['funding'][0]['funding_status']).to eql('planned')
    end
    it 'sets the :funding_status to granted if there is a grant_id' do
      dmp['project'] = JSON.parse([{ funding: [{ name: 'Foo', grant_id: { type: 'other', identifier: '123' } }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['project'][0]['funding'][0]['funding_status']).to eql('granted')
    end
    it 'does not add :funding if the :project has none defined' do
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['project']).to eql([])
    end
    it 'removes blank :project :start dates' do
      dmp['project'] = JSON.parse([{ start: '' }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['project'][0]['start']).to be(nil)
    end
    it 'removes blank :project :end dates' do
      dmp['project'] = JSON.parse([{ end: '' }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['project'][0]['end']).to be(nil)
    end
    it 'properly converts the :dataset :size' do
      dmp['dataset'] = JSON.parse([{ size: { unit: 'GB', value: '1' }, distribution: [{ title: 'hey' }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['dataset'][0]['distribution'][0]['byte_size']).to eql(1073741824)
    end
    it 'adds a :title to the :distribution' do
      dmp['dataset'] = JSON.parse([{ title: 'Foo', distribution: [{ description: 'hey' }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['dataset'][0]['distribution'][0]['title']).to eql("Proposed distribution of 'Foo'")
    end
    it 'looks up and adds the :host :url' do
      repo = create(:repository)
      dmp['dataset'] = JSON.parse([{ distribution: [{ host: { title: repo.name } }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['dataset'][0]['distribution'][0]['host']['url']).to eql(repo.homepage)
    end
    it 'sets the :distribution :data_access level to "closed" if there is pii data' do
      dmp['dataset'] = JSON.parse([{ personal_data: 'yes', distribution: [{ description: 'hey' }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['dataset'][0]['distribution'][0]['data_access']).to eql('closed')
    end
    it 'sets the :distribution :data_access level to "shared" if there is sensitive data but no pii data' do
      dmp['dataset'] = JSON.parse([{ sensitive_data: 'yes', distribution: [{ description: 'hey' }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['dataset'][0]['distribution'][0]['data_access']).to eql('shared')
    end
    it 'sets the :distribution :data_access level to "open" if there is no pii or sensitive data' do
      dmp['dataset'] = JSON.parse([{ distribution: [{ description: 'hey' }] }].to_json)
      result = draft.send(:ensure_defaults, dmp: dmp)
      expect(result['dataset'][0]['distribution'][0]['data_access']).to eql('open')
    end
  end

  describe 'designate_contact' do
    let!(:user) { create(:user) }
    let!(:draft) { create(:draft, user: user) }

    it 'returns the owner of the Draft as the :contact if no :contributor has `contact: true`' do
      contact = draft.send(:designate_contact)
      expect(contact.present?).to be(true)
      expect(contact['mbox']).to eql(user.email)
    end
    it 'returns the first :contributor that has `contact: true` as the :contact' do
      draft.metadata['dmp']['contributor'] = JSON.parse([
        { name: 'contributor1', mbox: 'c1@foo.org', role: ['foo'], contributor_id: { type: 'hey', identifier: 'there' },
          contact: true },
        { name: 'contributor2', role: ['bar'] },
        { name: 'contributor3', mbox: 'c3@foo.org', role: ['baz'], contributor_id: { type: 'orcid', identifier: '0000' },
          contact: true }
      ].to_json)

      expected = { name: 'contributor1', mbox: 'c1@foo.org', contact_id: { type: 'other', identifier: 'c1@foo.org' } }
      contact = draft.send(:designate_contact)
      expect(contact).to eql(JSON.parse(expected.to_json))
    end
  end

  describe 'owner_to_contact' do
    let!(:user) { create(:user) }
    let!(:draft) { create(:draft, user: user) }

    it 'returns nil if the draft has no :user_id' do
      draft.user_id = 1234455
      expect(draft.send(:designate_contact)).to be(nil)
    end
    it 'returns the owner of the Draft as a :contact using the email when no orcid is present' do
      contact = draft.send(:designate_contact)
      expect(contact.present?).to be(true)
      expect(contact['name']).to eql([user.surname, user.firstname].join(', '))
      expect(contact['mbox']).to eql(user.email)
      expect(contact['contact_id']).to eql(JSON.parse({ type: 'other', identifier: user.email }.to_json))
    end

    it 'returns the owner of the Draft as a :contact using the email when no orcid is present' do
      orcid = create_orcid(user: user)
      contact = draft.send(:designate_contact)
      expect(contact.present?).to be(true)
      expect(contact['name']).to eql([user.surname, user.firstname].join(', '))
      expect(contact['mbox']).to eql(user.email)
      expect(contact['contact_id']).to eql(JSON.parse({ type: 'orcid', identifier: orcid.value }.to_json))
    end
  end

  describe 'process_byte_size(unit:, size:)' do
    let!(:draft) { build(:draft) }

    it 'returns nil if :unit is nil' do
      expect(draft.send(:process_byte_size, unit: nil, size: 'abc')).to be(nil)
    end

    it 'returns nil if size if not an Integer or Float' do
      expect(draft.send(:process_byte_size, unit: 'kb', size: 'abc')).to be(nil)
    end
    it 'properly converts KB' do
      expected = 1024
      expect(draft.send(:process_byte_size, unit: 'kb', size: 1)).to eql(expected)
    end
    it 'properly converts MB' do
      expected = 1048576
      expect(draft.send(:process_byte_size, unit: 'mb', size: 1)).to eql(expected)
    end
    it 'properly converts GB' do
      expected = 1073741824
      expect(draft.send(:process_byte_size, unit: 'gb', size: 1)).to eql(expected)
    end
    it 'properly converts TB' do
      expected = 1099511627776
      expect(draft.send(:process_byte_size, unit: 'tb', size: 1)).to eql(expected)
    end
    it 'properly converts PB' do
      expected = 1125899906842624
      expect(draft.send(:process_byte_size, unit: 'pb', size: 1)).to eql(expected)
    end
    it 'returns bytes as is' do
      expected = 1
      expect(draft.send(:process_byte_size, unit: 'foo', size: 1)).to eql(expected)
    end
  end

  it 'test a minimal Draft JSON is properly converted for DMP ID registration' do
    user = create(:user)
    draft = create(:draft, user: user)
    draft.metadata = JSON.parse({ dmp: { title: 'Test 25' } }.to_json)
    expected = JSON.parse({
      dmp: {
        title: 'Test 25',
        dmp_id: { type: 'url', identifier: Rails.application.routes.url_helpers.api_v3_url(draft) },
        contact: {
          name: [user.surname, user.firstname].join(', '),
          mbox: user.email,
          contact_id: { type: 'other', identifier: user.email },
          dmproadmap_affiliation: { name: user.org.name }
        },
        dataset: [],
        project: [],
        dmproadmap_privacy: 'private'
      }
    }.to_json)
    expect(JSON.parse(draft.to_json_for_registration)).to eql(expected)
  end
  it 'test a complete Draft JSON is properly converted for DMP ID registration' do
    user = create(:user)
    draft = create(:draft, user: user)
    repo = create(:repository)
    funder = create(:registry_org)
    org = create(:registry_org)

    draft.metadata = JSON.parse({
      dmp: {
        title: 'Test 26',
        created: '2023-09-21T16:12:07Z',
		    dataset: [
          {
            type: 'sound',
            title: 'Nothing but a G thing',
            distribution: [{ host: { title: repo.name } }],
            sensitive_data: 'yes'
          }
		    ],
		    project: [
          {
            end: '2024-01-12T00:00:00-08:00',
            start: '2023-09-29T00:00:00-07:00',
            title: 'Complete  Project Name',
            funding: [
              {
                name: funder.name,
                funder_id: { type: 'ror', identifier: funder.ror_id },
                grant_id: { type: 'url', identifier: 'http://awards.nasa.gov/12345' },
                dmproadmap_project_number: 'Project-12345',
                dmproadmap_opportunity_number: 'Opportunity-98765'
              }
            ],
            description: 'Lorem Ipsum'
          }
        ],
		    modified: '2023-09-21T16:22:17Z',
		    contributor: [
          {
            mbox: 'snoop@death-row-records.com',
            name: 'Snoop, Dogg',
            role: ['investigation'],
            contact: true,
            contributor_id: { type: 'orcid', identifier: '0000-1111-222S-NOOP' },
            dmproadmap_affiliation: { name: org.name, affiliation_id: { type: 'ror', identifier: org.ror_id } }
          }
        ],
		    dmproadmap_privacy: 'public'
      }
    }.to_json)

    expected = JSON.parse({
      dmp: {
        title: 'Test 26',
        created: '2023-09-21T16:12:07Z',
        contact: {
          mbox: 'snoop@death-row-records.com',
          name: 'Snoop, Dogg',
          contact_id: { type: 'orcid', identifier: '0000-1111-222S-NOOP' },
          dmproadmap_affiliation: {
            name: org.name,
            affiliation_id: { type: 'ror', identifier: org.ror_id }
          }
        },
        dmp_id: { type: 'url', identifier: Rails.application.routes.url_helpers.api_v3_url(draft) },
		    dataset: [
          {
            type: 'sound',
            title: 'Nothing but a G thing',
            distribution: [
              {
                host: {
                  url: repo.homepage,
                  title: repo.name
                },
                title: 'Proposed distribution of \'Nothing but a G thing\'',
                data_access: 'shared'
              }
            ],
            sensitive_data: 'yes'
          }
		    ],
		    project: [
          {
            end: '2024-01-12T00:00:00-08:00',
            start: '2023-09-29T00:00:00-07:00',
            title: 'Complete  Project Name',
            funding: [
              {
                name: funder.name,
                grant_id: { type: 'url', identifier: 'http://awards.nasa.gov/12345' },
                funder_id: { type: 'ror', identifier: funder.ror_id },
                funding_status: 'granted',
                dmproadmap_project_number: 'Project-12345',
                dmproadmap_opportunity_number: 'Opportunity-98765'
              }
            ],
            description: 'Lorem Ipsum'
          }
        ],
		    modified: '2023-09-21T16:22:17Z',
		    contributor: [
          {
            mbox: 'snoop@death-row-records.com',
            name: 'Snoop, Dogg',
            role: ['investigation'],
            contributor_id: { type: 'orcid', identifier: '0000-1111-222S-NOOP' },
            dmproadmap_affiliation: {
              name: org.name,
              affiliation_id: { type: 'ror', identifier: org.ror_id }
            }
          }
        ],
		    dmproadmap_privacy: 'public'
      }
    }.to_json)

    result = JSON.parse(draft.to_json_for_registration)
    expect(result['dmp']['contact']).to eql(expected['dmp']['contact'])
    expect(result['dmp']['dataset']).to eql(expected['dmp']['dataset'])
    expect(result['dmp']['project']).to eql(expected['dmp']['project'])
    expect(result['dmp']['contributor']).to eql(expected['dmp']['contributor'])
    expect(result).to eql(expected)
  end
end
