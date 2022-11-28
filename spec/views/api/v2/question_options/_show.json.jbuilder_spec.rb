# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/question_options/_show.json.jbuilder' do
  before do
    @question_option = create(:question_option)

    render partial: 'api/v2/question_options/show', locals: { question_option: @question_option }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe 'includes all of the question_option attributes' do
    it 'includes :is_default' do
      expect(@json[:is_default]).to eql(@question_option.is_default)
    end

    it 'includes :number' do
      expect(@json[:number]).to eql(@question_option.number)
    end

    it 'includes :text' do
      expect(@json[:text]).to eql(@question_option.text)
    end

    it 'includes the :created' do
      expect(@json[:created]).to eql(@question_option.created_at.to_formatted_s(:iso8601))
    end

    it 'includes the :modified' do
      expect(@json[:modified]).to eql(@question_option.updated_at.to_formatted_s(:iso8601))
    end

    it 'includes :question_id' do
      expect(@json[:question_id]).to eql(@question_option.question_id)
    end
  end
end
