# frozen_string_literal: true

require "rails_helper"

describe UsageHelper do
  include UsageHelper

  context "chart data preparation" do
    describe "#prep_data_for_yearly_users_chart" do
      it "defers to #default_chart_prep" do
        expects(:default_chart_prep).with(data: nil)
        prep_data_for_yearly_users_chart(data: nil)
      end
    end

    describe "#prep_data_for_yearly_plans_chart" do
      it "properly formats the data " do
        expects(:default_chart_prep).with(data: nil)
        prep_data_for_yearly_plans_chart(data: nil)
      end
    end

    describe "#prep_data_for_template_plans_chart" do
      # chart.js expects the following JSON format for the plans by template
      # chart (referred to as stacked on the chart.js site):
      #
      # {
      #   "labels": ["Dec-19", "Oct-19" ],
      #   "datasets": [
      #     {
      #       "label": "lorem",
      #       "backgroundColor": "rgb(117,40,65)",
      #       "data": [
      #         {"x": 7, "y": "Dec-19" },
      #         {"x": 3, "y": "Oct-19" }
      #       ]
      #     }
      #   ]
      # }
      it "returns an empty hash if no data was available" do
        expected = {
          "labels": [Date.today.last_month.end_of_month.strftime("%b-%y")],
          "datasets": []
        }
        expect(prep_data_for_template_plans_chart(data: nil)).to eql(expected.to_json)
      end

      context "with data" do
        before(:each) do
          @template1 = { name: Faker::Lorem.unique.word, count: Faker::Number.number(digits: 1) }
          @template2 = { name: Faker::Lorem.unique.word, count: Faker::Number.number(digits: 1) }
          @last_month = Date.today.last_month.end_of_month
          @two_months = Date.today.months_ago(2).end_of_month

          # Mock some Stat records
          @data = [
            build(:stat_created_plan, date: @last_month,
                                      details: { "by_template": [@template1] }).to_json,
            build(:stat_created_plan, date: @two_months,
                                      details: { "by_template": [@template2] }).to_json
          ]

          @json = JSON.parse(prep_data_for_template_plans_chart(data: @data))
          @first = @json["datasets"].first
          @second = @json["datasets"].last
        end

        it "sorts the results by date descending" do
          expected = [
            prep_date_for_charts(date: @last_month),
            prep_date_for_charts(date: @two_months)
          ]
          expect(@json["labels"]).to eql(expected)
        end

        it "properly organizes the data for template 1" do
          expect(@first["label"]).to eql(@template1[:name])
          expect(@first["backgroundColor"].starts_with?("rgb")).to eql(true)
          @first["data"].each do |hash|
            case hash["y"]
            when prep_date_for_charts(date: @last_month)
              expect(hash["x"]).to eql(@template1[:count])
            else
              expect(hash["x"]).to eql(0)
            end
          end
        end
        it "properly organizes the data for template 2" do
          expect(@second["label"]).to eql(@template2[:name])
          expect(@second["backgroundColor"].starts_with?("rgb")).to eql(true)
          @second["data"].each do |hash|
            case hash["y"]
            when prep_date_for_charts(date: @two_months)
              expect(hash["x"]).to eql(@template2[:count])
            else
              expect(hash["x"]).to eql(0)
            end
          end
        end
      end
    end
  end

  describe "#plans_per_template_ranges" do
    [1, 3, 6, 9, 12].each do |months|
      it "returns an option for #{months} ago" do
        date = Date.today.months_ago(months).end_of_month
        expect(plans_per_template_ranges.map { |i| i[1] }.include?(date)).to eql(true)
      end
    end
  end

  describe "#default_chart_prep" do
    # chart.js expects the following JSON format for a standard bar chart:
    #
    # {
    #   "Dec-19": 3,
    #   "Oct-19": 1
    # }
    it "converts a StatCreatedPlan" do
      data = build(:stat_created_plan, details: { "by_template": [] })
      expected = { "#{prep_date_for_charts(date: data.date)}": data.count }.to_json
      expect(default_chart_prep(data: [data.to_json])).to eql(JSON.parse(expected))
    end
    it "converts a StatJoinedUser" do
      data = build(:stat_joined_user)
      expected = { "#{prep_date_for_charts(date: data.date)}": data.count }.to_json
      expect(default_chart_prep(data: [data.to_json])).to eql(JSON.parse(expected))
    end
  end

  describe "#prep_date_for_charts" do
    it "converts the date" do
      rslt = prep_date_for_charts(date: Date.today.to_s)
      expect(rslt).to eql(Date.today.strftime("%b-%y"))
    end
  end

  describe "#random_rgb" do
    it "returns a random RGB value" do
      rgb_regex = /^rgb\((\d{1,3}),(\d{1,3}),(\d{1,3})\)$/
      expect(random_rgb =~ rgb_regex).to eql(0)
    end
  end
end
