# frozen_string_literal: true

require "rails_helper"

describe "api/v1/plans/_project.json.jbuilder" do

  before(:each) do
    @plan = build(:plan, funder: build(:org, :funder))
    render partial: "api/v1/plans/project", locals: { plan: @plan }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the project attributes" do
    it "includes :title" do
      expect(@json[:title]).to eql(@plan.title)
    end
    it "includes :description" do
      expect(@json[:description]).to eql(@plan.description)
    end
    it "includes :start" do
      expect(@json[:start]).to eql(@plan.start_date.to_formatted_s(:iso8601))
    end
    it "includes :end" do
      expect(@json[:end]).to eql(@plan.end_date.to_formatted_s(:iso8601))
    end

    it "includes the :funder" do
      expect(@json[:funding].length).to eql(1)
    end
  end

end
