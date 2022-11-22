# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/phases/_show.json.jbuilder' do
  before do
    @phase = create(:phase, sections: 1)
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

    it 'includes :created' do
      expect(@json[:created]).to eql(@phase.created_at.to_formatted_s(:iso8601))
    end

    it 'includes :modified' do
      expect(@json[:modified]).to eql(@phase.updated_at.to_formatted_s(:iso8601))
    end

    it 'includes :sections' do
      expect(@json[:sections].length).to be(1)
    end
  end
end
