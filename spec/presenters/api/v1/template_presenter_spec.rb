# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TemplatePresenter do
  describe '#title' do
    before do
      @org = create(:org)
      @template = build(:template, customization_of: nil, org: @org)
    end

    it 'returns the template title if its not a customization' do
      presenter = described_class.new(template: @template)
      expect(presenter.title).to eql(@template.title)
    end

    it 'returns the template title and Org name if it is a customization' do
      @template.customization_of = Faker::Number.number
      presenter = described_class.new(template: @template)
      expect(presenter.title.start_with?(@template.title)).to be(true)
      expect(presenter.title.end_with?(@org.name)).to be(true)
    end
  end
end
