# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/questions/_show.json.jbuilder' do
  before do
    @question = create(:question)
    render partial: 'api/v2/questions/show', locals: { question: @question }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe 'includes all of the question attributes' do
    it 'includes :default_value' do
      expect(@json[:default_value]).to eql(@question.default_value)
    end

    it 'includes :text' do
      expect(@json[:text]).to eql(@question.text)
    end

    it 'includes :number' do
      expect(@json[:number]).to eql(@question.number)
    end

    it 'includes :option_comment_display' do
      expect(@json[:option_comment_display]).to be(true)
    end

    it 'includes :section_id' do
      expect(@json[:section_id]).to eql(@question.section_id)
    end

    it 'includes :question_format_id' do
      expect(@json[:question_format_id]).to eql(@question.question_format_id)
    end

    it 'includes :modifiable' do
      expect(@json[:modifiable]).to eql(@question.modifiable)
    end

    it 'includes the :created' do
      expect(@json[:created]).to eql(@question.created_at.to_formatted_s(:iso8601))
    end

    it 'includes the :modified' do
      expect(@json[:modified]).to eql(@question.updated_at.to_formatted_s(:iso8601))
    end

    it 'not includes the :annotations' do
      expect(@json[:annotations].length).to be(0)
    end

    it 'not includes the :question_options' do
      expect(@json[:question_options].length).to be(0)
    end
  end
end
