# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/sections/_show.json.jbuilder' do
  before do
    @section = create(:section, questions: 1)

    render partial: 'api/v2/sections/show', locals: { section: @section }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe 'includes all of the section attributes' do
    it 'includes :title' do
      expect(@json[:title]).to eql(@section.title)
    end

    it 'includes :description' do
      expect(@json[:description]).to eql(@section.description)
    end

    it 'includes :number' do
      expect(@json[:number]).to eql(@section.number)
    end

    it 'includes :phase_id' do
      expect(@json[:phase_id]).to eql(@section.phase_id)
    end

    it 'includes :modifiable' do
      expect(@json[:modifiable]).to eql(@section.modifiable)
    end

    it 'includes the :created' do
      expect(@json[:created]).to eql(@section.created_at.to_formatted_s(:iso8601))
    end

    it 'includes the :modified' do
      expect(@json[:modified]).to eql(@section.updated_at.to_formatted_s(:iso8601))
    end

    it 'includes the :questions' do
      expect(@json[:questions].length).to be(1)
    end
  end
end
