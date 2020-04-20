# frozen_string_literal: true

require "rails_helper"

RSpec.describe DateRangeable do

  # Using the Plan model for testing this Concern
  before(:each) do
    @plans_in_range = [
      create(:plan, created_at: Date.today - 31.days, updated_at: Date.today - 31.days),
      create(:plan, created_at: Date.today - 31.days, updated_at: Date.today - 31.days)
    ]
    @plan_prior = create(:plan, created_at: Date.today - 90.days,
                                updated_at: Date.today - 90.days)
    @plan_after = create(:plan, created_at: Date.today, updated_at: Date.today)
  end

  context "class methods" do

    describe "#date_range?(term:)" do
      it "returns true the 'Oct 2019' format" do
        expect(Plan.date_range?(term: "Jan 19")).to eql(true)
        expect(Plan.date_range?(term: "Jan 2019")).to eql(true)
        expect(Plan.date_range?(term: "January 2019")).to eql(true)
        expect(Plan.date_range?(term: Date.today.strftime("%b %Y"))).to eql(true)
      end
      it "returns false for others" do
        expect(Plan.date_range?(term: "01 19")).to eql(false)
        expect(Plan.date_range?(term: "01 2019")).to eql(false)
        expect(Plan.date_range?(term: "1st Jan 2019")).to eql(false)
        expect(Plan.date_range?(term: "01-01-2019")).to eql(false)
        expect(Plan.date_range?(term: "01/01/2019")).to eql(false)
        expect(Plan.date_range?(term: "2019-01-01")).to eql(false)
        expect(Plan.date_range?(term: "2019-01-01 00:00:01")).to eql(false)
      end
    end

    describe "#by_date_range(field, term)" do
      before(:each) do
        @term = (Date.today - 31.days).strftime("%b %Y")
      end

      it "searches by the specified field" do
        expect(Plan.by_date_range(:created_at, @term).length).to eql(2)
        expect(Plan.by_date_range(:updated_at, @term).length).to eql(2)
      end
      it "returns the expected records" do
        results = Plan.by_date_range(:created_at, @term)
        results.each { |r| expect(@plans_in_range.include?(r)).to eql(true) }
      end
      it "does not return records from a prior month" do
        results = Plan.by_date_range(:created_at, @term)
        expect(results.include?(@plan_prior)).to eql(false)
      end
      it "does not return records from a later month" do
        results = Plan.by_date_range(:created_at, @term)
        expect(results.include?(@plan_after)).to eql(false)
      end
    end

  end

end
