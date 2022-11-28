# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/annotations/_show.json.jbuilder' do
  before do
    @annotation = create(:annotation)

    render partial: 'api/v2/annotations/show', locals: { annotation: @annotation }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe 'includes all of the annotation attributes' do
    it 'includes :text' do
      expect(@json[:text]).to eql(@annotation.text)
    end

    it 'includes :type' do
      expect(@json[:type]).to eql(@annotation.type)
    end

    it 'includes :question_id' do
      expect(@json[:question_id]).to eql(@annotation.question_id)
    end

    it 'includes :org_id' do
      expect(@json[:org_id]).to eql(@annotation.org_id)
    end

    it 'includes the :created' do
      expect(@json[:created]).to eql(@annotation.created_at.to_formatted_s(:iso8601))
    end

    it 'includes the :modified' do
      expect(@json[:modified]).to eql(@annotation.updated_at.to_formatted_s(:iso8601))
    end
  end
end
