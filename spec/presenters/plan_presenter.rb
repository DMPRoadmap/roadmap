# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlanPresenter do

  before(:each) do
    @plan = build(:plan, start_date: nil, end_date: nil)
    @presenter = described_class.new(@plan)
  end

  describe "#project_dates_to_readonly_display" do
    it "returns blank if no start_date or end_date" do
      expect(@presenter.project_dates_to_readonly_display).to eql("")
    end
    it "returns 'Starts on [:date]' if end_date is nil" do
      @plan.start_date = Time.now
      expected = @presenter.project_dates_to_readonly_display
      expect(expected.start_with?("Starts on")).to eql(true)
    end
    it "returns 'Ends on [:date]' if start_date is nil" do
      @plan.end_date = Time.now
      expected = @presenter.project_dates_to_readonly_display
      expect(expected.start_with?("Ends on")).to eql(true)
    end
    it "returns '[:date] to [:date]' start_date end_date are present" do
      @plan.start_date = Time.now
      @plan.end_date = Time.now + 2.months
      expected = @presenter.project_dates_to_readonly_display
      expect(expected.include?(" to ")).to eql(true)
    end
  end

end
