# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatJoinedUser, type: :model do
  before(:example) do
    @org = FactoryBot.create(:org)
  end

  describe ".to_json" do
    it "returns only the count and date if no details are defined" do
      stat = build(:stat_joined_user)
      json = JSON.parse(stat.to_json)
      expect(json["count"]).to eql(stat.count)
      expect(json["date"]).to eql(stat.date.strftime("%Y-%m-%d"))
      expect(json["by_template"]).to eql(nil)
      expect(json["org_id"]).to eql(nil)
      expect(json["created_at"]).to eql(nil)
    end
  end
  describe ".to_csv" do
    context "when no instances" do
      it "returns empty" do
        csv = described_class.to_csv([])

        expect(csv).to be_empty
      end
    end
    context "when instances" do
      let(:org) { FactoryBot.create(:org) }
      it "returns instances in a comma-separated row" do
        may = FactoryBot.create(:stat_joined_user, date: Date.new(2018, 0o5, 31),
                                                   org: org, count: 20)
        june = FactoryBot.create(:stat_joined_user, date: Date.new(2018, 0o6, 30),
                                                    org: org, count: 10)
        data = [may, june]

        csv = described_class.to_csv(data)

        expected_csv = <<~HERE
          Date,Count
          2018-05-31,20
          2018-06-30,10
        HERE
        expect(csv).to eq(expected_csv)
      end
    end
  end
end
