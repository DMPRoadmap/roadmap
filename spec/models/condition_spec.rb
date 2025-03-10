# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Condition, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :question }
  end

  describe 'condition with action_type "remove"' do
    describe '.deep_copy with no options passed in.' do
      let!(:question) { build(:question) }

      let!(:condition) do
        build(:condition, question: question, option_list: [1, 5],
                          action_type: 'remove',
                          remove_data: [7, 8, 9])
      end

      subject { condition.deep_copy }

      it 'creates a new record' do
        expect(subject).not_to eql(condition)
      end
      it 'copies the option_list attribute' do
        expect(subject.option_list).to contain_exactly(1, 5)
      end

      it 'copies the action_type attribute' do
        expect(subject.action_type).to eql('remove')
      end

      it 'copies the remove_data attribute' do
        expect(subject.remove_data).to contain_exactly(7, 8, 9)
      end

      it 'copies the  webhook_data attribute' do
        expect(subject.webhook_data).to be nil
      end
    end

    describe '.deep_copy with options passed in.' do
      let!(:question) { build(:question) }

      let!(:condition) do
        build(:condition, question: question, option_list: [1, 5],
                          action_type: 'remove',
                          remove_data: [7, 8, 9])
      end
      let!(:options) { { option_list: [100, 101], action_type: 'remove', remove_data: [200, 220] } }

      subject { condition.deep_copy(**options) }

      it 'creates a new record' do
        expect(subject).not_to eql(condition)
      end
      it 'replaces the option_list attribute with passed option_list' do
        expect(subject.option_list).to contain_exactly(100, 101)
      end

      it 'replaces the action_type attribute with passed in action_type' do
        expect(subject.action_type).to eql('remove')
      end

      it 'replaces the remove_data attribute with passed in remove_data' do
        expect(subject.remove_data).to contain_exactly(200, 220)
      end

      it 'copies the webhook_data attribute' do
        expect(subject.webhook_data).to eql(condition.webhook_data)
      end
    end
  end

  describe 'condition with action_type "add_webhook"' do
    describe '.deep_copy with no options passed in.' do
      let!(:question) { build(:question) }

      # condition with action_type "add_webhook" using :webhook trait
      let!(:condition) do
        build(:condition, :webhook, question: question)
      end

      subject { condition.deep_copy }

      it 'creates a new record' do
        expect(subject).not_to eql(condition)
      end
      it 'copies the option_list attribute' do
        expect(subject.option_list).to eq([])
      end

      it 'copies the action_type attribute' do
        expect(subject.action_type).to eql('add_webhook')
      end

      it 'copies the remove_data attribute' do
        expect(subject.remove_data).to eq([])
      end

      it 'copies the  webhook_data attribute' do
        expect(subject.webhook_data).to eq(condition.webhook_data)
      end
    end

    describe '.deep_copy with options passed in.' do
      let!(:question) { build(:question) }

      let!(:condition) do
        build(:condition, :webhook, question: question)
      end

      # rubocop:disable Layout/LineLength
      let!(:option_web_data) { '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}' }
      # rubocop:enable Layout/LineLength

      let!(:options) do
        { option_list: [], action_type: 'add_webhook', remove_data: [],
          webhook_data: option_web_data }
      end

      subject { condition.deep_copy(**options) }

      it 'creates a new record' do
        expect(subject).not_to eql(condition)
      end
      it 'replaces the option_list attribute with passed option_list' do
        expect(subject.option_list).to eq([])
      end

      it 'replaces the action_type attribute with passed in action_type' do
        expect(subject.action_type).to eql('add_webhook')
      end

      it 'replaces the remove_data attribute with passed in remove_data' do
        expect(subject.remove_data).to eq([])
      end

      it 'copies the webhook_data attribute' do
        expect(subject.webhook_data).to eq(option_web_data)
      end
    end
  end
end
