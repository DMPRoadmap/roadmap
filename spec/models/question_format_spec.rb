# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormat, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }

    it {
      is_expected.to validate_uniqueness_of(:title).case_insensitive
                                                   .with_message('must be unique')
    }

    it { is_expected.to validate_presence_of(:description) }

    it { is_expected.to allow_values(true, false).for(:option_based) }

    it { is_expected.not_to allow_value(nil).for(:option_based) }

    it {
      is_expected.to allow_values(:textarea, :textfield, :radiobuttons,
                                  :checkbox, :dropdown, :multiselectbox,
                                  :date, :rda_metadata)
        .for(:formattype)
    }
  end

  context 'associations' do
    it { is_expected.to have_many(:questions) }
  end

  describe '.id_for' do
    let!(:format_type) { 'textarea' }

    subject { QuestionFormat.id_for(format_type) }

    context "when record doesn't exist" do
      it 'it returns nil' do
        # TODO: This behaviour is fixed in the refactors branch
        expect(subject).to be_nil
      end
    end

    context 'when record exists' do
      before do
        @question_format = create(:question_format, formattype: 'textarea')
      end

      it 'returns the ID for that record' do
        expect(subject).to eql(@question_format.id)
      end
    end
  end

  describe '#to_s' do
    let!(:question_format) { create(:question_format) }

    it 'returns the title' do
      expect(question_format.to_s).to eql(question_format.title)
    end
  end

  describe '#option_based?' do
    subject { question_format.option_based? }

    context 'when question_format option_based is true' do
      let!(:question_format) { create(:question_format, option_based: true) }

      it { is_expected.to eql(true) }
    end

    context 'when question_format option_based is true' do
      let!(:question_format) { create(:question_format, option_based: false) }

      it { is_expected.to eql(false) }
    end
  end

  describe '#formattype' do
    it 'raises an exception when value not recognised' do
      expect { subject.formattype = :foo }.to raise_error(ArgumentError)
    end
  end
end
