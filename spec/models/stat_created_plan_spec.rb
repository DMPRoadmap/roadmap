# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatCreatedPlan, type: :model do
  describe ".to_json" do
    it "returns only the count and date if no details are defined" do
      stat = build(:stat_created_plan)
      json = JSON.parse(stat.to_json)
      expect(json["count"]).to eql(stat.count)
      expect(json["date"]).to eql(stat.date.strftime("%Y-%m-%d"))
      expect(json["by_template"]).to eql([])
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

      context "when no details" do
        it "returns counts in a comma-separated row" do
          may = FactoryBot.create(:stat_created_plan,
                                  date: Date.new(2018, 0o5, 31),
                                  org: org, count: 20)
          june = FactoryBot.create(:stat_created_plan,
                                   date: Date.new(2018, 0o6, 30),
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

      context "when details by template is true" do
        it "returns counts by_template in a comma-separated row" do
          may = FactoryBot.create(:stat_created_plan,
                                  date: Date.new(2018, 0o5, 31),
                                  org: org,
                                  count: 20,
                                  details: { by_template: [
                                    { name: "Template1", count: 5 },
                                    { name: "Template2", count: 15 }
                                  ] })
          june = FactoryBot.create(:stat_created_plan,
                                   date: Date.new(2018, 0o6, 30),
                                   org: org, count: 10,
                                   details: { by_template: [
                                     { name: "Template1", count: 2 },
                                     { name: "Template3", count: 8 }
                                   ] })
          july = FactoryBot.create(:stat_created_plan,
                                   date: Date.new(2018, 0o7, 31),
                                   org: org,
                                   count: 0)
          data = [may, june, july]

          csv = described_class.to_csv(data, details: { by_template: true, sep: "," })

          expected_csv = <<~HERE
            Date,Template1,Template2,Template3,Count
            May 2018,5,15,0,20
            Jun 2018,2,0,8,10
            Jul 2018,0,0,0,0
          HERE
          expect(csv).to eq(expected_csv)
        end
      end
    end
  end

  describe ".serialize" do
    let(:org) do
      FactoryBot.create(:org,
                        name: "An Org",
                        contact_email: "foo@bar.com",
                        contact_name: "Foo")
    end
    let(:details) do
      { "by_template" => [
        { "name" => "Template 1", "count" => 10 },
        { "name" => "Template 2", "count" => 10 }
      ] }
    end

    it "retrieves JSON details as a hash object" do
      FactoryBot.create(:stat_created_plan,
                        date: "2018-09-30",
                        org: org,
                        count: 20,
                        details: details)

      json_details = described_class.find_by_date("2018-09-30").details

      expect(json_details).to eq(details)
    end
  end
end
