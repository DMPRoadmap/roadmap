# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgSelectionPresenter do

  before(:each) do
    @org = create(:org)
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

  describe "#crosswalk_entry_from_org_id(value:)" do
    it "return an empty hash if the value is blank" do
      expect(@presenter.crosswalk_entry_from_org_id(value: nil)).to eql("{}")
    end
    it "return an empty hash if the value is not an integer" do
      expect(@presenter.crosswalk_entry_from_org_id(value: "a123")).to eql("{}")
    end
    it "return an empty hash if the value does not have a match in crosswalk" do
      expect(@presenter.crosswalk_entry_from_org_id(value: "999")).to eql("{}")
    end
    it "return ther correct crosswalk entry" do
      rslt = @presenter.crosswalk_entry_from_org_id(value: @org.id.to_s)
      expected = OrgSelection::OrgToHashService.to_hash(org: @org).to_json
      expect(rslt).to eql(expected)
    end
  end

end
