# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wip do
  context 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:user) }

    describe 'validates the :metadata' do
      let!(:user) { create(:user, :org_admin) }
      let!(:error_msg) { 'Metadata must contain a title. For example: `{ dmp: { title: \'Test\' } }`' }

      it 'is true if metadata structure contains a top level :dmp and at least a :title' do
        wip = build(:wip, user: user, metadata: { dmp: { title: Faker::Music::PearlJam.song } })
        expect(wip.valid?).to be(true)
      end
      it 'is false if there is no top level :dmp' do
        wip = build(:wip, user: user, metadata: { foo: { title: Faker::Music::PearlJam.song } })
        expect(wip.valid?).to be(false)
        expect(wip.errors.full_messages.first).to eql(error_msg)
      end
      it 'is false if the :dmp does not contain a :title' do
        wip = build(:wip, user: user, metadata: { dmp: { description: Faker::Music::PearlJam.song } })
        expect(wip.valid?).to be(false)
        expect(wip.errors.full_messages.first).to eql(error_msg)
      end
    end
  end

  it 'generates an :identifier when saving a new record' do

  end
end
