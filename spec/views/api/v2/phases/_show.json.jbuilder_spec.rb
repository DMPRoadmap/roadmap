# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/phases/_show.json.jbuilder' do
  before(:each) do
    scheme = create(:identifier_scheme, name: 'ror')
    @phase = create(:phase)
    @ident = create(:identifier, value: Faker::Lorem.word, identifiable: @phase,
                    identifier_scheme: scheme)
    @org.reload
    render partial: 'api/v2/phases/show', locals: { phase: @phase }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe 'includes all of the phase attributes' do
    it 'includes :title' do
      expect(@json[:title]).to eql(@phase.title)
    end
    it 'includes :description' do
      expect(@json[:description]).to eql(@phase.description)
    end
    it 'includes :number' do
      expect(@json[:number]).to eql(@phase.number)
    end
    it 'includes :template_id' do
      expect(@json[:template_id]).to eql(@phase.template_id)
    end
    it 'includes :modifiable' do
      expect(@json[:modifiable]).to eql(@phase.modifiable)
    end
    it 'includes :modifiable' do
      expect(@json[:modifiable]).to eql(@phase.modifiable)
    end
    it 'includes the :created' do
      expect(@template[:created]).to eql(@phase.created_at.to_formatted_s(:iso8601))
    end
    it 'includes the :modified' do
      expect(@template[:modified]).to eql(@phase.updated_at.to_formatted_s(:iso8601))
    end
    it 'includes the :sections' do
      expect(@json[:sections].length).to eql(1)
    end
  end
end
