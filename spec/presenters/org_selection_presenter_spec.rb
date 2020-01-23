# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgSelectionPresenter do

  before(:each) do
    @org = build(:org)
    @orgs = [@org, build(:org)]
    @presenter = described_class.new(orgs: @orgs, selection: @org)
  end

  describe "#name" do
    it "returns blank if no selection is defined" do
      presenter = described_class.new(orgs: @orgs, selection: nil)
      expect(presenter.name).to eql("")
    end
    it "#name returns blank" do
      expect(@presenter.name).to eql(@org.name)
    end
  end

  it "#crosswalk returns an array containing the Orgs as hashes" do
    rslt = JSON.parse(@presenter.crosswalk)
    @orgs.each do |org|
      expected = OrgSelection::OrgToHashService.to_hash(org: org).to_json
      expect(rslt.include?(JSON.parse(expected))).to eql(true)
    end
  end

  it "#select_list returns an array of the Org names" do
    expect(@presenter.select_list.include?(@org.name)).to eql(true)
  end

end
