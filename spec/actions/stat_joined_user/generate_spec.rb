require 'rails_helper'
require_relative '../../../app/actions/stat_joined_user/generate'

RSpec.describe Actions::StatJoinedUser::Generate do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018,04,01))
  end
  describe '.full' do
    it "returns monthly aggregates since org's creation" do
      april = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,04,03,0,0,0)), FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,04,04,0,0,0))]
      may = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,05,03,0,0,0))] 
      june = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,06,03,0,0,0)), FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,06,04,0,0,0))]

      described_class.full(org)

      april = StatJoinedUser.find_by(date: '2018-04-30', org_id: org.id).count
      may = StatJoinedUser.find_by(date: '2018-05-31', org_id: org.id).count
      june = StatJoinedUser.find_by(date: '2018-06-30', org_id: org.id).count
      july = StatJoinedUser.find_by(date: '2018-07-31', org_id: org.id).count
      expect([april, may, june, july]).to eq([2,1,2,0])
    end
  end

  describe '.last_month' do
    it "returns aggregates from today's last month" do
      5.times do
        FactoryBot.create(:user, org: org, created_at: Date.today.last_month)
      end

      described_class.last_month(org)

      last_month = StatJoinedUser.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
      expect(last_month).to eq(5)
    end
  end

  describe '.full_all_orgs' do
    it "returns monthly aggregates for each org since their creation" do
      Org.expects(:all).returns([org])
      april = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,04,03,0,0,0)), FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,04,04,0,0,0))]
      may = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,05,03,0,0,0))] 
      june = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,06,03,0,0,0)), FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,06,04,0,0,0))]

      described_class.full_all_orgs

      april = StatJoinedUser.find_by(date: '2018-04-30', org_id: org.id).count
      may = StatJoinedUser.find_by(date: '2018-05-31', org_id: org.id).count
      june = StatJoinedUser.find_by(date: '2018-06-30', org_id: org.id).count
      july = StatJoinedUser.find_by(date: '2018-07-31', org_id: org.id).count
      expect([april, may, june, july]).to eq([2,1,2,0])
    end
  end

  describe '.last_month_all_orgs' do
    it "returns aggregates from today's last month" do
      Org.expects(:all).returns([org])
      5.times do
        FactoryBot.create(:user, org: org, created_at: Date.today.last_month)
      end

      described_class.last_month_all_orgs

      last_month = StatJoinedUser.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
      expect(last_month).to eq(5)
    end
  end
end
