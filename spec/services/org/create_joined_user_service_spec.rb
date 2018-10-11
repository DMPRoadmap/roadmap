require 'rails_helper'

RSpec.describe Org::CreateJoinedUserService do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018,04,01))
  end
  describe '.call' do
    context 'when an org is passed' do
      it "generates monthly aggregates since org's creation" do
        april = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,04,03,0,0,0)), FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,04,04,0,0,0))]
        may = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,05,03,0,0,0))] 
        june = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,06,03,0,0,0)), FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,06,04,0,0,0))]

        described_class.call(org)

        april = StatJoinedUser.find_by(date: '2018-04-30', org_id: org.id).count
        may = StatJoinedUser.find_by(date: '2018-05-31', org_id: org.id).count
        june = StatJoinedUser.find_by(date: '2018-06-30', org_id: org.id).count
        july = StatJoinedUser.find_by(date: '2018-07-31', org_id: org.id).count
        expect([april, may, june, july]).to eq([2,1,2,0])
      end
    end

    context 'when no org is passed' do
      it "generates monthly aggregates for each org since their creation" do
        Org.expects(:all).returns([org])
        april = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,04,03,0,0,0)), FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,04,04,0,0,0))]
        may = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,05,03,0,0,0))] 
        june = [FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,06,03,0,0,0)), FactoryBot.create(:user, org: org, created_at: DateTime.new(2018,06,04,0,0,0))]

        described_class.call

        april = StatJoinedUser.find_by(date: '2018-04-30', org_id: org.id).count
        may = StatJoinedUser.find_by(date: '2018-05-31', org_id: org.id).count
        june = StatJoinedUser.find_by(date: '2018-06-30', org_id: org.id).count
        july = StatJoinedUser.find_by(date: '2018-07-31', org_id: org.id).count
        expect([april, may, june, july]).to eq([2,1,2,0])
      end
    end
  end
end
